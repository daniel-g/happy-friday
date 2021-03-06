require 'spec_helper'

describe TeamSchedule::Canvan do
  let!(:team) { FactoryGirl.create(:team) }
  let!(:task_1) { FactoryGirl.create(:task, team: team) }
  let!(:task_2) { FactoryGirl.create(:task, team: team) }

  subject(:schedule) { TeamSchedule::Canvan.new(team: team) }

  it 'sets tasks sorted by id' do
    expect(schedule.tasks).to eq([task_1, task_2])
  end

  it 'takes next task' do
    task = schedule.take_task!
    expect(task).to be_kind_of(TeamSchedule::Task)
    expect(task.task.id).to eq(task_1.id)
  end

  it 'tells if the team is done' do
    team.tasks.each{|task| schedule.take_task! }
    expect(schedule).to be_done
  end
end
