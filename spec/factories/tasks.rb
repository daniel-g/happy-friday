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

FactoryGirl.define do
  factory :task do
    qa_estimation 1
    dev_estimation 1
    team
    sequence(:external_id)
  end

  factory :unassigned_task, parent: :task do
    team nil
  end
end
