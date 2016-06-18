class Report
  attr_accessor :file

  def initialize(file_name: nil)
    @file = File.open(file_name || default_file_name, 'w')
  end

  def generate!
    CSV.open(file, 'wb',
      write_headers: true,
      headers: headers ) do |csv|
        until team_schedules.all?(&:done?) do
          team_schedules.reject(&:done?).each do |team_schedule|
            write(csv: csv, task: team_schedule.take_task!)
          end
        end
    end
  end

  private

  def team_schedules
    @team_schedules ||= teams.map{|team| TeamSchedule.new(team: team)}
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

  def write(csv:, task:)
    csv << [
      task.team_name,
      task.local_schedule,
      task.utc_schedule,
      task.external_id
    ]
  end
end
