class Manager
  include Singleton

  def team_of_reference
    @team_of_reference ||= Team.order(:timezone).last
  end

  def assing_all_tasks!
    raise 'No teams to assign' if Team.count.zero?
    raise 'No tasks to assign' if Task.count.zero?
    Task.unassigned.find_each do |task|
      # Whoever lasts the least, taking into account:
      # hours of sleeping
      # current load of work
      # hours that task would cost to the team
      team = Team.all.min_by do |team|
        team.hours_behind_of(team_of_reference) +
        team.current_load +
        team.hours_for(task)
      end
      team.tasks << task
    end
  end
end
