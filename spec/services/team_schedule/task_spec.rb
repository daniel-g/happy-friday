require 'spec_helper'

describe TeamSchedule::Task do
  let!(:team) { FactoryGirl.create(:team, timezone: -5) }
  let!(:task) { FactoryGirl.create(:task, team: team) }

  subject(:scheduled_task) { TeamSchedule::Task.new(task: task, local_time: 9) }

  it 'tells what team belongs to' do
    expect(scheduled_task.team_name).to eq(task.team.name)
  end

  it 'tells its schedule in local time of the team' do
    expect(scheduled_task.local_schedule).to eq('9:00am - 11:00am')
  end

  it 'tells its schedule in utc' do
    expect(scheduled_task.utc_schedule).to eq('2:00pm - 4:00pm')
  end

  it 'tells its external id' do
    expect(scheduled_task.external_id).to eq(task.external_id)
  end
end
