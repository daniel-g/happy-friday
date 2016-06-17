class Manager
  include Singleton

  def assing_all_tasks!
    raise 'No teams to assign' if Team.count.zero?
    raise 'No tasks to assign' if Task.count.zero?
    perform_basic_assignation
    perform_exchanges
  end

  private

  def perform_basic_assignation
    Task.update_all(team_id: Team.first.id)
  end

  def perform_exchanges
    Team.find_each do |team|
      team.tasks.find_each do |task|
        Team.where.not(id: team).find_each do |compare_team|
          perform_team_exchange(task, compare_team)
          compare_team.tasks.find_each do |compare_task|
            perform_task_exchange(task, compare_task)
          end
        end
      end
    end
  end

  def perform_team_exchange(task, team)
    current_team = task.team
    current_total_time = Team.last_team_to_finsh.finish_hour_in_eastern_team
    task.switch_team(to: team)
    if current_total_time < Team.last_team_to_finsh.finish_hour_in_eastern_team
      task.switch_team(to: current_team)
    end
  end

  def perform_task_exchange(task, compare_task)
    current_total_time = Team.last_team_to_finsh.finish_hour_in_eastern_team
    task.switch_team(with: compare_task)
    if current_total_time < Team.last_team_to_finsh.finish_hour_in_eastern_team
      task.switch_team(with: compare_task)
    end
  end
end
