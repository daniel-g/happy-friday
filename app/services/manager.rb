class TeamSchedule::Manager
  include Singleton

  def assing_all_tasks!
    raise 'No teams to assign' if Team.count.zero?
    raise 'No tasks to assign' if Task.count.zero?
    Task.update_all(team_id: Team.first.id)
    reassign!
  end

  private

  def reassign!
    Team.find_each do |team|
      team.tasks.find_each do |task|
        assign_best_team!(task: task, teams: Team.where.not(id: team))
      end
    end
  end

  def assign_best_team!(task:, teams:)
    teams.find_each do |team|
      try_switching_team(task: task, team: team)
      team.tasks.find_each do |other_task|
        try_switching_tasks(task: task, other_task: other_task)
      end
    end
  end

  def try_switching_team(task:, team:)
    current_team = task.team
    current_total_time = Team.last_team_to_finsh.finish_hour_utc
    task.switch_to_team(team)
    if current_total_time < Team.last_team_to_finsh.finish_hour_utc
      task.switch_to_team(current_team)
    end
  end

  def try_switching_tasks(task:, other_task:)
    current_total_time = Team.last_team_to_finsh.finish_hour_utc
    task.switch_team_with_task(other_task)
    if current_total_time < Team.last_team_to_finsh.finish_hour_utc
      task.switch_team_with_task(other_task)
    end
  end
end
