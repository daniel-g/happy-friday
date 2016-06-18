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

  scope :eastern_team, ->{ order(:timezone).last }
  scope :with_tasks, ->{
    joins('LEFT JOIN tasks ON teams.id = tasks.team_id').
    where.not(tasks: { id: nil }).
    uniq
  }

  def self.last_team_to_finsh
    all.max_by(&:finish_hour_in_eastern_team)
  end

  def finish_hour_in_eastern_team
    CHECK_IN_TEAM + hours_behind_of_eastern_team + current_load
  end

  private

  def hours_behind_of_eastern_team
    @hours_behind_of_eastern_team ||= Team.eastern_team.timezone - timezone
  end

  def current_load
    tasks.team_cost
  end
end
