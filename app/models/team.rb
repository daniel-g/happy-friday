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

  def team_of_reference
    @team_of_reference ||= Team.order(:timezone).last
  end

  def self.find_best_for(task)
    all.min_by do |team|
      team.finish_hour_in_eastern_team +
      team.hours_for(task)
    end
  end

  def self.last_team_to_finsh
    all.max_by(&:finish_hour_in_eastern_team)
  end

  def finish_hour_in_eastern_team
    CHECK_IN_TEAM + hours_behind_of(team_of_reference) + current_load
  end

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
