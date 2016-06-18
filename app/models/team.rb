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
  CHECK_IN_TEAM = 9

  has_many :tasks

  scope :with_tasks, ->{
    joins('LEFT JOIN tasks ON teams.id = tasks.team_id').
    where.not(tasks: { id: nil }).
    uniq
  }

  def self.last_team_to_finsh
    all.max_by(&:finish_hour_utc)
  end

  def finish_hour_utc
    CHECK_IN_TEAM - timezone + current_load
  end

  private

  def current_load
    tasks.team_cost
  end
end
