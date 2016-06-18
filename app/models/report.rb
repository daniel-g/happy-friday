class Report
  def generate!(file_name: nil)
    CSV.open(file_name || default_file_name, 'wb',
      write_headers: true,
      headers: headers ) do |csv|
        while(team_schedules.any?) do
          team_schedules.each do |team_schedule|
            if task = team_schedule.take_task
              write_to(csv: csv, task: task)
            else
              team_schedules.delete_at(
                team_schedules.index(team_schedule)
              )
            end
          end
        end
    end
  end

  private

  def team_schedules
    @team_schedules ||= Team.with_tasks.order('timezone DESC').map{|team| TeamSchedule.new(team: team)}
  end

  def default_file_name
    Framework.app.root.join('reports', "#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")
  end

  def headers
    ['TEAM', 'Local time', 'UTC time', 'TASK No.']
  end

  def write_to(csv:, task:)
    csv << [
      task.team_name,
      task.local_schedule,
      task.utc_schedule,
      task.task_number
    ]
  end
end
