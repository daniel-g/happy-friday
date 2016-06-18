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
      'tasks.qa_estimation/teams.qa_performance + tasks.dev_estimation/teams.dev_performance'
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

  def team_cost
    raise 'No team assigned' unless team
    qa_estimation/team.qa_performance + dev_estimation/team.dev_performance
  end
end
