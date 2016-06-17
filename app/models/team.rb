# == Schema Information
#
# Table name: teams
#
#  id              :integer          not null, primary key
#  name            :string
#  timezone        :decimal(6, 2)
#  qa_performance  :decimal(6, 2)
#  dev_performance :decimal(6, 2)
#

class Team < ActiveRecord::Base
  has_many :tasks

  def hours_for(task)
    task.qa_estimation/qa_performance + task.dev_estimation/dev_performance
  end

  def current_load
    tasks.reduce(0){|result, task| result + hours_for(task) }
  end

  def hours_behind_of(team)
    team.timezone - timezone
  end
end
