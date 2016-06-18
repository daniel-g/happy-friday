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

  def switch_to_team(new_team)
    self.team = new_team
    save
  end

  def switch_team_with_task(other_task)
    new_team = other_task.team
    other_task.team = self.team
    self.team = new_team
    other_task.save
    self.save
  end

  def team_cost
    raise 'No team assigned' unless team
    qa_estimation/team.qa_performance + dev_estimation/team.dev_performance
  end
end
