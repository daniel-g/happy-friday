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

FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "team#{n}" }
    timezone 0
    qa_performance 1
    dev_performance 1
  end
end
