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
end
