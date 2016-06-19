class TeamSchedule::Manager
  include Singleton

  # Performs the assignation of all tasks in the database.
  # Looks for the best schedule in order to finish all teams ASAP
  #
  def assing_all_tasks!
    raise 'No teams to assign' if Team.count.zero?
    raise 'No tasks to assign' if Task.count.zero?

    Task.update_all(team_id: nil)

    basic_assign

    optimize
  end

  private

  # Performs basic assignations of tasks
  # so that optimization doesn't take a lot of time
  #
  def basic_assign
    Task.find_each do |task|
      # Whoever lasts the least, takes the job
      team = Team.all.min_by do |team|
        team.finish_hour_utc +
        task.team_cost(for_team: team)
      end
      team.tasks << task
    end
  end

  # Optimizes the current task assignations
  #
  def optimize
    Team.find_each do |team|
      team.tasks.find_each do |task|
        assign_best_team(task: task, teams: Team.where.not(id: team))
      end
    end
  end

  # Performs exchange of tasks if needed: from team to team or from task to task
  # in the list of teams specified
  #
  # @param [Task] task the task
  # @param [Array<Team>] teams teams where to look at
  def assign_best_team(task:, teams:)
    teams.find_each do |team|
      # No need to look at the team tasks if it was changed to this team
      next if try_switching_team(task: task, team: team)

      # Look at the team tasks and see if the task can be switched
      team.tasks.find_each do |other_task|
        # No need to look at the new team tasks if it was changed to this same team
        break if try_switching_tasks(task: task, other_task: other_task)
      end
    end
  end

  # Switches a tasks to another team in order to gain time
  #
  # @param [Task] task the task
  # @param [Team] team the team
  # @return [true, false] true if the switch gains time, false if it didn't switch
  def try_switching_team(task:, team:)
    current_team = task.team
    old_time, new_time = benchmark{ task.switch_to_team(team) }
    return true if old_time >= new_time

    # Otherwise, switch back
    task.switch_to_team(current_team)
    return false
  end

  # Switches 2 tasks in teams in order to gain time
  #
  # @param [Task] task one task
  # @param [Task] other_task the other task
  # @return [true, false] true if the switch gains time, false if it didn't switch
  def try_switching_tasks(task:, other_task:)
    old_time, new_time = benchmark{ task.switch_team_with_task(other_task) }
    return true if old_time >= new_time

    # Otherwise, switch back
    task.switch_team_with_task(other_task)
    return false
  end

  # Calculates the hour all teams will finish in utc
  # before and after a block of code is executed
  #
  # @param [Proc] block block of code to execute
  # @return [Array<Float, Float>] 2 elements array, the first with the current time, the second with the new time
  def benchmark(&block)
    old_total_time = Team.last_team_to_finsh.finish_hour_utc
    block.call
    new_total_time = Team.last_team_to_finsh.finish_hour_utc
    [old_total_time, new_total_time]
  end
end
