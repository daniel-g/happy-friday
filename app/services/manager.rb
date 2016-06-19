class TeamSchedule::Manager
  include Singleton

  def assing_all_tasks!
    raise 'No teams to assign' if Team.count.zero?
    raise 'No tasks to assign' if Task.count.zero?
    Task.update_all(team_id: nil)
    basic_assign!
    optimize!
  end

  private

  # Performs basic assignations of tasks
  # so that optimization doesn't take a lot of time
  def basic_assign!
    Task.find_each do |task|
      # Whoever lasts the least, takes the job
      team = Team.all.min_by do |team|
        team.finish_hour_utc +
        task.team_cost(for_team: team)
      end
      team.tasks << task
    end
  end

  # Performs exchange of tasks if needed: from team to team or from task to task
  def optimize!
    Team.find_each do |team|
      team.tasks.find_each do |task|
        assign_best_team!(task: task, teams: Team.where.not(id: team))
      end
    end
  end

  def assign_best_team!(task:, teams:)
    teams.find_each do |team|
      if try_switching_team(task: task, team: team)
        # No need to look at the team tasks if it was changed to this team
        next
      else
        # Look at the team tasks and see if the task can be switched
        team.tasks.find_each do |other_task|
          # No need to look at the new team tasks if it was changed to this same team
          break if try_switching_tasks(task: task, other_task: other_task)
        end
      end
    end
  end

  def try_switching_team(task:, team:)
    current_team = task.team
    current_total_time = Team.last_team_to_finsh.finish_hour_utc
    task.switch_to_team(team)
    if current_total_time < Team.last_team_to_finsh.finish_hour_utc
      task.switch_to_team(current_team)
      return false
    else
      return true
    end
  end

  def try_switching_tasks(task:, other_task:)
    current_total_time = Team.last_team_to_finsh.finish_hour_utc
    task.switch_team_with_task(other_task)
    if current_total_time < Team.last_team_to_finsh.finish_hour_utc
      task.switch_team_with_task(other_task)
      false
    else
      true
    end
  end
end
