# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  qa_estimation  :integer          default(0)
#  dev_estimation :integer          default(0)
#  team_id        :integer
#  external_id    :integer
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
end
