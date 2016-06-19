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

  # Hour where all teams start working local, in 24 hours format.
  CHECK_IN_TEAM = 9

  # Tasks assigned to this team
  # @return [ActiveRecord::Association<Task>] the tasks
  # @!method tasks
  has_many :tasks

  # Teams with at least a task assigned
  # @return [Team::ActiveRecord_Relation] the teams
  # @!scope class
  # @!method with_tasks
  scope :with_tasks, ->{ joins(:tasks).uniq }

  # Returns last team to finish if all were moved to UTC
  #
  # @return [Team] the team
  def self.last_team_to_finsh
    all.max_by(&:finish_hour_utc)
  end

  # Calculates the finish hour in 24 hour format in hours,
  # depending on the check in hour, its timezone moved to utc, and its current load of tasks
  #
  # @return [Float] the finish hour in 24 hour format in hours.
  def finish_hour_utc
    CHECK_IN_TEAM - timezone + current_load
  end

  private

  # Calculates the current load of tasks assigned
  #
  # @return [Float] the total load of tasks in hours
  def current_load
    tasks.team_cost
  end
end
