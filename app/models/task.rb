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
  scope :assigned, ->{ where.not(team_id: nil) }

  def self.unassign_all!
    update_all(team_id: nil)
  end

  def switch_team(to: nil, with: nil)
    if to.present?
      self.team = to
      save
    elsif with.present?
      new_team = with.team
      with.team = self.team
      self.team = new_team
      with.save
      self.save
    end
  end
end
