require 'spec_helper'

describe TeamSchedule::Manager do
  context 'teams with different timezones' do
    let!(:east_team){ FactoryGirl.create(:team, timezone: 2) }
    let!(:west_team){ FactoryGirl.create(:team, timezone: -2) }

    let!(:task_1){ FactoryGirl.create(:unassigned_task, external_id: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, external_id: 2) }

    it 'assigns tasks in order to all finish at 1pm utc' do
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(11)
    end

    it 'assigns tasks in order to finish at 2pm utc' do
      task_1.update_attributes(dev_estimation: 3, qa_estimation: 2) # => first team works until 12pm (utc)
      task_2.update_attributes(dev_estimation: 0.5, qa_estimation: 0.5) # => second team starts working 11am, finish 12pm (utc)
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(12)
    end
  end

  context 'teams with the same timezone' do
    let!(:london_1){ FactoryGirl.create(:team) }
    let!(:london_2){ FactoryGirl.create(:team) }

    let!(:task_1){ FactoryGirl.create(:unassigned_task, external_id: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, external_id: 2) }

    it 'assigns tasks in order to all finish at 1pm utc (very slow to receive a task)' do
      london_2.update_attributes(dev_performance: 0.1)
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh).to eq(london_1)
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(13)
    end

    it 'assigns tasks in order to all finish at 2pm utc (equilibrated)' do
      london_1.update_attributes(dev_performance: 1, qa_performance: 0.5)
      london_2.update_attributes(dev_performance: 0.5, qa_performance: 1)
      task_1.update_attributes(dev_estimation: 2, qa_estimation: 1) # => london 1 finish at 1pm
      task_2.update_attributes(dev_estimation: 2, qa_estimation: 1) # => london 2 finish at 2pm
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh).to eq(london_2)
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(14)
    end
  end

  context 'teams different timezones with different performances' do
    let!(:task_1){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 2) }
    let!(:task_3){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 2, external_id: 3) }

    let!(:moscow){ FactoryGirl.create(:team, timezone: 3, dev_performance: 1, qa_performance: 0.5) }
    let!(:zagreb){ FactoryGirl.create(:team, timezone: 2, dev_performance: 0.25, qa_performance: 0.25) }
    let!(:london){ FactoryGirl.create(:team, timezone: 0, dev_performance: 1, qa_performance: 1) }

    it 'assigns tasks in order to all finish at 2pm utc time' do
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh).to eq(moscow)
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(14)
    end
  end

  context 'teams different timezones with different performances: hard case' do
    let!(:task_1){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 2) }
    let!(:task_3){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 2, external_id: 3) }
    let!(:task_4){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 2, external_id: 4) }

    let!(:moscow){ FactoryGirl.create(:team, name: 'Moscow', timezone: 3, dev_performance: 1, qa_performance: 0.5) }
    let!(:zagreb){ FactoryGirl.create(:team, name: 'Zagreb', timezone: 2, dev_performance: 0.25, qa_performance: 0.25) }
    let!(:london){ FactoryGirl.create(:team, name: 'London', timezone: 0, dev_performance: 0.5, qa_performance: 1) }

    it 'assigns tasks in order to all finish at 6pm utc' do
      TeamSchedule::Manager.instance.assing_all_tasks!
      expect(Team.last_team_to_finsh).to eq(london)
      expect(Team.last_team_to_finsh.finish_hour_utc).to eq(18)
    end
  end
end
