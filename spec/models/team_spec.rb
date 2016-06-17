require 'spec_helper'

describe Team do
  let!(:task){ FactoryGirl.create(:task, team: team, qa_estimation: 1, dev_estimation: 2) }
  let(:team){ FactoryGirl.create(:team, qa_performance: 0.5, dev_performance: 1) }

  it 'calculates the time it takes to build a task' do
    # => 2 hours for development + 2 hours for qa
    expect(team.hours_for(task)).to eq(4)
  end

  it 'calculates how busy it is with given tasks' do
    hard_task = FactoryGirl.create(:task, team: team, qa_estimation: 2, dev_estimation: 4)
    expect(team.current_load).to eq(team.hours_for(task) + team.hours_for(hard_task))
  end

  it 'calculates the hours behind with another team' do
    team.timezone = 5
    west_team = FactoryGirl.create(:team, timezone: -6)
    expect(west_team.hours_behind_of(team)).to eq(11)
  end

  it 'calculates the eastern team' do
    east_team = FactoryGirl.create(:team, timezone: 2)
    east_team_2 = FactoryGirl.create(:team, timezone: 1)
    west_team = FactoryGirl.create(:team, timezone: -2)
    expect(Team.eastern_team). to eq east_team
  end

  it 'calculates the hour to finish in the team of reference' do
    eastern_team = FactoryGirl.create(:team, timezone: 2)
    # => 4 hours of the task + 2 hours of difference with the eastern team
    expect(team.finish_hour_in_eastern_team).to eq 6
  end

  it 'has the tasks assigned to the team' do
    expect(team.tasks).to include(task)
  end
end
