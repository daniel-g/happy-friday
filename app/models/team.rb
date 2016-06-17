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

  CHECK_IN_TEAM = 9

  def self.last_team_to_finsh
    all.max_by(&:finish_hour_in_eastern_team)
  end

  def finish_hour_in_eastern_team
    CHECK_IN_TEAM + hours_behind_of(Team.eastern_team) + current_load
  end

  private

  def self.eastern_team
    order(:timezone).last
  end

  def hours_behind_of(team)
    team.timezone - timezone
  end

  def current_load
    tasks.reduce(0){|result, task| result + hours_for(task) }
  end

  def hours_for(task)
    task.qa_estimation/qa_performance + task.dev_estimation/dev_performance
  end
end
