class Report
  attr_accessor :file_name

  def initialize(file_name: nil)
    raise 'Directory does not exist' if file_name.present? && !File.directory?(File.dirname(file_name))
    @file_name = file_name || default_file_name
  end

  def data
    @data = []
    until team_schedules.all?(&:done?) do
      team_schedules.reject(&:done?).each do |team_schedule|
        @data << team_schedule.take_task!.to_h
      end
    end
    @data
  end

  def generate!
    CSV.open(file_name, 'wb', write_headers: true, headers: headers) do |csv|
      data.each do |task|
        csv << [
          task[:team_name],
          task[:local_schedule],
          task[:utc_schedule],
          task[:external_id]
        ]
      end
    end
  end

  private

  def team_schedules
    @team_schedules ||= teams.map{|team| TeamSchedule::Canvan.new(team: team)}
  end

  def teams
    @teams ||= Team.with_tasks.order('timezone DESC')
  end

  def default_file_name
    Framework.app.root.join('reports', "#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")
  end

  def headers
    ['TEAM', 'Local time', 'UTC time', 'TASK No.']
  end
end
