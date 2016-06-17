require 'spec_helper'

describe Team do
  let(:task){ FactoryGirl.build(:task) }
  let(:team){ task.team }

  it 'tells the time it takes to build a task' do
    team.dev_performance = 1
    task.dev_estimation = 2
    team.qa_performance = 0.5
    task.qa_estimation = 1
    expect(team.hours_for(task)).to eq(2 + 2)
  end
  it 'tells how busy it would be on receiving a task'
  it 'tells the hours in difference with another team'
  it 'tells the tasks assigned to the team'
end
