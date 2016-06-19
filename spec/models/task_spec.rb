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
  let(:task){ FactoryGirl.create(:task) }

  it 'switches task to another team' do
    new_team = FactoryGirl.create(:team)
    expect(task.team).to_not be(new_team)
    task.switch_to_team(new_team)
    expect(task.reload.team).to eq(new_team)
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
    let(:moscow){ FactoryGirl.create(:team, dev_performance: 1, qa_performance: 0.5) }
    let(:zagreb){ FactoryGirl.create(:team, dev_performance: 0.5, qa_performance: 1) }
    let(:london){ FactoryGirl.create(:team, dev_performance: 0.25, qa_performance: 0.25) }
    let(:moscow_task){ FactoryGirl.create(:task, team: moscow, dev_estimation: 3, qa_estimation: 5) }
    let(:zagreb_task){ FactoryGirl.create(:task, team: zagreb, dev_estimation: 3, qa_estimation: 5) }
    let(:london_task){ FactoryGirl.create(:task, team: london, dev_estimation: 3, qa_estimation: 5) }

    it 'calculates the cost of a task for the team assigned' do
      expect(moscow_task.team_cost).to eq(13)
    end

    it 'calculates the cost of a group of tasks for the team assigned' do
      total_cost = [moscow_task, zagreb_task, london_task].sum(&:team_cost)
      expect(Task.team_cost).to eq(total_cost)
    end

    it 'raises an exception if no team assigned to that task' do
      task = FactoryGirl.create(:unassigned_task)
      expect{ task.team_cost }.to raise_error(RuntimeError)
    end
  end
end
