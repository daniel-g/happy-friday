require 'spec_helper'

describe Team do
  let!(:task){ FactoryGirl.create(:task, team: team, qa_estimation: 1, dev_estimation: 2) }
  let(:team){ FactoryGirl.create(:team, qa_performance: 0.5, dev_performance: 1) }

  it 'tells the time it takes to build a task' do
    expect(team.hours_for(task)).to eq(2 + 2)
  end

  it 'tells how busy it is with given tasks' do
    hard_task = FactoryGirl.create(:task, team: team, qa_estimation: 2, dev_estimation: 4)
    expect(team.current_load).to eq(team.hours_for(task) + team.hours_for(hard_task))
  end

  it 'tells the hours in difference with another team' do
    team.timezone = 5
    west_team = FactoryGirl.create(:team, timezone: -6)
    expect(team.hours_ahead_of(west_team)).to eq(11)
  end

  it 'has the tasks assigned to the team' do
    expect(team.tasks).to include(task)
  end
end
