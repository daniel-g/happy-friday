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
  belongs_to :team

  scope :team_cost, ->{
    includes(:team).sum(
      'tasks.qa_estimation/teams.qa_performance' \
      '+ tasks.dev_estimation/teams.dev_performance'
    )
  }

  def switch_to_team(new_team)
    self.update_attributes(team: new_team)
  end

  def switch_team_with_task(other_task)
    new_team = other_task.team
    other_task.update_attributes(team: self.team)
    self.update_attributes(team: new_team)
  end

  def team_cost(for_team: nil)
    calc_team = for_team || team
    raise 'No team assigned' unless calc_team
    qa_cost_for_team(calc_team) + dev_cost_for_team(calc_team)
  end

  private

  def qa_cost_for_team(for_team)
    qa_estimation/for_team.qa_performance
  end

  def dev_cost_for_team(for_team)
    dev_estimation/for_team.dev_performance
  end
end
