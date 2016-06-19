# == Schema Information
#
# Table name: teams
#
#  id              :integer          not null, primary key
#  name            :string
#  timezone        :decimal(6, 2)
#  qa_performance  :decimal(6, 2)
#  dev_performance :decimal(6, 2)
#

require 'spec_helper'

describe Team do
  let!(:task){ FactoryGirl.create(:task, team: team, qa_estimation: 1, dev_estimation: 2) }
  let(:team){ FactoryGirl.create(:team, qa_performance: 0.5, dev_performance: 1) }

  it 'calculates the hour to finish in utc, given the check in time' do
    # Hour to finish => check in hour + dev + qa
    expect(team.finish_hour_utc).to eq(Team::CHECK_IN_TEAM + task.team_cost)
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
    let!(:moscow){ FactoryGirl.create(:team, timezone: 3, dev_performance: 1, qa_performance: 0.5) }
    let!(:zagreb){ FactoryGirl.create(:team, timezone: 2, dev_performance: 0.25, qa_performance: 0.25) }
    let!(:london){ FactoryGirl.create(:team, timezone: 0, dev_performance: 1, qa_performance: 1) }

    let!(:moscow_task){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 2, external_id: 1, team: moscow) }
    let!(:zagreb_task){ FactoryGirl.create(:unassigned_task, dev_estimation: 2, qa_estimation: 1, external_id: 2, team: zagreb) }
    let!(:london_task){ FactoryGirl.create(:unassigned_task, dev_estimation: 1, qa_estimation: 1, external_id: 3, team: london) }

    it 'calculates based on task estimations in utc' do
      # Time to finish = dev + qa + check in hour
      # => Moscow: 2 + 4 + 9 = 15
      # => Zagreb: 8 + 4 + 9 = 21 <- last team to finish tasks
      # => London: 1 + 1 + 9 = 11
      expect(Team.last_team_to_finsh).to eq(zagreb)
    end
  end
end
