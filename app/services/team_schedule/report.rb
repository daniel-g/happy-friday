class Report
  def data
    @data = []
    until team_schedules.all?(&:done?) do
      team_schedules.reject(&:done?).each do |team_schedule|
        @data << team_schedule.take_task!.to_h
      end
    end
    @data
  end

  def generate_csv(file_name: nil)
    Report::CSVGenerator.new(report: self, file_name: file_name).generate
  end

  private

  def team_schedules
    @team_schedules ||= teams.map{|team| TeamSchedule::Canvan.new(team: team)}
  end

  def teams
    @teams ||= Team.with_tasks.order('timezone DESC')
  end
end
