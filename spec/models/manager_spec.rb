require 'spec_helper'

describe Manager do

  # let!(:task_3){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 2) }
  # let!(:task_4){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 2) }

  let!(:task_1){ FactoryGirl.create(:unassigned_task) }
  let!(:task_2){ FactoryGirl.create(:unassigned_task) }

  it 'calculates the team of reference as the eastern team in timezone' do
    east_team = FactoryGirl.create(:team, timezone: 2)
    west_team = FactoryGirl.create(:team, timezone: -2)
    expect(Manager.instance.team_of_reference). to eq east_team
  end

  context 'teams with different timezones' do
    let!(:east_team){ FactoryGirl.create(:team, timezone: 2) }
    let!(:west_team){ FactoryGirl.create(:team, timezone: -2) }

    it 'assigns tasks first to the east team' do
      Manager.instance.assing_all_tasks!
      expect(east_team.tasks).to match_array([task_1, task_2])
    end

    it 'assigns the next task if it makes sense due to the timezone' do
      task_1.update_attributes(dev_estimation: 3, qa_estimation: 2) # => first team keeps working until 10am (Z -2)
      task_2.update_attributes(dev_estimation: 0.5, qa_estimation: 0.5) # => second team can get this 1 hour and finish at the same time
      Manager.instance.assing_all_tasks!
      expect(east_team.tasks).to match_array([task_1])
      expect(west_team.tasks).to match_array([task_2])
    end

    it 'assigns the next task to the first team in equal circumstances' do
      task_1.update_attributes(dev_estimation: 2, qa_estimation: 2) # => first team keeps working until 9am (Z -2)
      Manager.instance.assing_all_tasks!
      expect(east_team.tasks).to match_array([task_1, task_2])
      expect(west_team.tasks).to be_empty
    end
  end

  context 'teams with the same timezone' do
    let!(:team_1){ FactoryGirl.create(:team) }
    let!(:team_2){ FactoryGirl.create(:team) }

    it 'assigns the task to the faster team' do
      team_2.update_attributes(dev_performance: 0.25)
      Manager.instance.assing_all_tasks!
      expect(team_1.tasks).to match_array([task_1, task_2])
    end

    it 'assigns the next task to the team with less load that makes it faster' do
      team_1.update_attributes(dev_performance: 1, qa_performance: 0.5)
      team_2.update_attributes(dev_performance: 0.5, qa_performance: 1)
      task_1.update_attributes(dev_estimation: 2, qa_estimation: 1) # => team 1 loads 4
      task_2.update_attributes(dev_estimation: 2, qa_estimation: 1) # => team 2 loads 5
                                                                    # => both finish in 5 hours :)
      Manager.instance.assing_all_tasks!
      expect(team_1.tasks).to match_array([task_1])
      expect(team_2.tasks).to match_array([task_2])
    end

    it 'assigns the next task to the first team in equal circumstances' do
      task_3 = FactoryGirl.create(:unassigned_task)
      Manager.instance.assing_all_tasks!
      expect(team_1.tasks).to match_array([task_1, task_3])
      expect(team_2.tasks).to match_array([task_2])
    end
  end

  context 'teams different timezones with different performances' do
    let!(:task_1){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1) }
    let!(:task_3){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 2) }

    let!(:moscow){ FactoryGirl.create(:team, timezone: 3, dev_performance: 1, qa_performance: 0.5) }
    let!(:zagreb){ FactoryGirl.create(:team, timezone: 2, dev_performance: 0.25, qa_performance: 0.25) }
    let!(:london){ FactoryGirl.create(:team, timezone: 0, dev_performance: 0.7, qa_performance: 1) }

    it 'assigns tasks accordingly' do
      Manager.instance.assing_all_tasks!
      expect(moscow.tasks).to match_array([task_1, task_3])
      expect(zagreb.tasks).to be_empty
      expect(london.tasks).to match_array([task_2])
    end
  end
end
