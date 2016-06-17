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

  scope :unassigned, ->{ where(team_id: nil) }
end
