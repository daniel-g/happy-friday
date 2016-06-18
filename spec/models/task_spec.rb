# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  qa_estimation  :decimal(6, 2)    default(0.0)
#  dev_estimation :decimal(6, 2)    default(0.0)
#  team_id        :integer
#  external_id    :string
#

require 'spec_helper'

describe Task do
  it 'switches task to another team' do
    task_1 = FactoryGirl.create(:task)
    new_team = FactoryGirl.create(:team)
    expect(task_1.team).to_not be(new_team)
    task_1.switch_to_team(new_team)
    expect(task_1.reload.team).to eq(new_team)
  end

  it 'switches team with another task' do
    task_1 = FactoryGirl.create(:task)
    task_2 = FactoryGirl.create(:task)
    new_team_1 = task_2.team
    new_team_2 = task_1.team
    expect(task_1.team).to_not eq(new_team_1)
    expect(task_2.team).to_not eq(new_team_2)
    task_1.switch_team_with_task(task_2)
    expect(task_1.reload.team).to eq(new_team_1)
    expect(task_2.reload.team).to eq(new_team_2)
  end

  describe 'cost for the team' do
    it 'calculates the cost of a task for the team assigned' do
      team = FactoryGirl.create(:team, dev_performance: 1, qa_performance: 0.5)
      task = FactoryGirl.create(:task, team: team, dev_estimation: 3, qa_estimation: 5)
      expect(task.team_cost).to eq(13)
    end

    it 'calculates the cost of a group of tasks for the team assigned' do
      team_1 = FactoryGirl.create(:team, dev_performance: 1, qa_performance: 0.5)
      team_2 = FactoryGirl.create(:team, dev_performance: 0.5, qa_performance: 1)
      team_3 = FactoryGirl.create(:team, dev_performance: 0.25, qa_performance: 0.25)
      task_1 = FactoryGirl.create(:task, team: team_1, dev_estimation: 3, qa_estimation: 5)
      task_2 = FactoryGirl.create(:task, team: team_2, dev_estimation: 3, qa_estimation: 5)
      task_3 = FactoryGirl.create(:task, team: team_3, dev_estimation: 3, qa_estimation: 5)
      expect(Task.team_cost).to eq(task_1.team_cost + task_2.team_cost + task_3.team_cost)
    end

    it 'raises an exception if no team assigned to that task' do
      task = FactoryGirl.create(:unassigned_task)
      expect{ task.team_cost }.to raise_error(RuntimeError)
    end
  end
end
