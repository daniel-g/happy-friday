require 'spec_helper'

describe Task do
  it 'loads unassigned tasks' do
    task_1 = FactoryGirl.create(:task)
    task_2 = FactoryGirl.create(:unassigned_task)
    expect(Task.unassigned).to match_array([task_2])
  end
end
