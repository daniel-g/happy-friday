# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  qa_estimation  :decimal(6, 2)    default(0.0)
#  dev_estimation :decimal(6, 2)    default(0.0)
#  team_id        :integer
#  external_id    :string
#

class Task < ActiveRecord::Base
  # Team assigned to this task
  # @return [Team] the team
  # @!method team
  belongs_to :team

  # Total hours taken for the tasks in the relation,
  # depending on the team assigned
  # @return [Float] the hours
  # @!scope class
  # @!method team_cost
  scope :team_cost, ->{
    includes(:team).sum(
      'tasks.qa_estimation/teams.qa_performance' \
      '+ tasks.dev_estimation/teams.dev_performance'
    )
  }

  # Switches task to a new team
  #
  # @param [Team] new_team the new team
  # @return [true, false] true if the switch was a success
  def switch_to_team(new_team)
    self.update_attributes(team: new_team)
  end

  # Switches teams of task and another task
  #
  # @param [Task] other_task the task for the switching
  # @return [true, false] true if the switch was a success
  def switch_team_with_task(other_task)
    new_team = other_task.team
    other_task.update_attributes(team: self.team)
    self.update_attributes(team: new_team)
  end

  # Calculates the cost in hours for the team assigned or for a team specified
  #
  # @param [Team] for_team: nil another team for the calculation, if don't want to use the team assigned
  # @return [Float] Hours that the team assigned or specified would last for this task
  def team_cost(for_team: nil)
    calc_team = for_team || team
    raise 'No team assigned' unless calc_team
    qa_cost_for_team(calc_team) + dev_cost_for_team(calc_team)
  end

  private

  # Calculates the qa cost in hours for a team
  #
  # @param [Team] for_team the team
  # @return [Float] Hours the team specified would last for the qa part of the task
  def qa_cost_for_team(for_team)
    qa_estimation/for_team.qa_performance
  end

  # Calculates the dev cost in hours for a team
  #
  # @param [Team] for_team the team
  # @return [Float] Hours the team specified would last for the dev part of the task
  def dev_cost_for_team(for_team)
    dev_estimation/for_team.dev_performance
  end
end
