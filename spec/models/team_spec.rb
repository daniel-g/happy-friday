require 'spec_helper'

describe Team do
  let!(:task){ FactoryGirl.create(:task, team: team, qa_estimation: 1, dev_estimation: 2) }
  let(:team){ FactoryGirl.create(:team, qa_performance: 0.5, dev_performance: 1) }

  it 'calculates the hour to finish in the team of reference, given the check in time' do
    # Hour to finish => dev + qa + difference with eastern team + check in hour
    eastern_team = FactoryGirl.create(:team, timezone: 2)
    expect(team.finish_hour_in_eastern_team).to eq(Team::CHECK_IN_TEAM + 6)
  end

  it 'gets teams with tasks' do
    team_without_tasks = FactoryGirl.create(:team)
    expect(Team.with_tasks).to include(team)
    expect(Team.with_tasks).to_not include(team_without_tasks)
  end

  it 'has the tasks assigned to the team' do
    expect(team.tasks).to include(task)
  end

  describe 'last team to finish' do
    let!(:task_1){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 2, external_id: 1) }
    let!(:task_2){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 2) }
    let!(:task_3){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 1, external_id: 3) }

    let!(:moscow){ FactoryGirl.create(:team, timezone: 3, dev_performance: 1, qa_performance: 0.5, tasks: [task_1]) }
    let!(:zagreb){ FactoryGirl.create(:team, timezone: 2, dev_performance: 0.25, qa_performance: 0.25, tasks: [task_2]) }
    let!(:london){ FactoryGirl.create(:team, timezone: 0, dev_performance: 1, qa_performance: 1, tasks: [task_3]) }

    it 'calculates based on task estimations and the eastern team' do
      # Time to finish = dev + qa + difference with eastern team + check in hour
      # (eastern team) => Moscow: 2 + 4 + 0 + 9 = 15
      #                => Zagreb: 8 + 4 + 1 + 9 = 22 <- last team to finish tasks
      #                => London: 1 + 1 + 3 + 9 = 14
      expect(Team.last_team_to_finsh).to eq(zagreb)
    end
  end
end
