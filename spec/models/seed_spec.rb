require "spec_helper"

describe Seed do
  it 'seeds teams' do
    Seed.instance.teams(
      teams_file: File.open(Framework.app.root.join('spec' , 'fixtures', 'teams.csv')),
      performance_file: File.open(Framework.app.root.join('spec' , 'fixtures', 'performance.csv'))
    )
    expect(Team.pluck(:name)).to eq(%w{ Moscow Zagreb London })
    expect(Team.pluck(:timezone)).to eq([3, 2, 0])
    expect(Team.pluck(:dev_performance)).to eq([1, 0.25, 0.5])
    expect(Team.pluck(:qa_performance)).to eq([0.5, 0.25, 1])
  end

  it 'seeds tasks' do
    Seed.instance.tasks(
      file: File.open(Framework.app.root.join('spec' , 'fixtures', 'tasks.csv'))
    )
    expect(Task.pluck(:qa_estimation)).to eq([1, 1, 2, 2])
    expect(Task.pluck(:dev_estimation)).to eq([2, 2, 1, 2])
    expect(Task.pluck(:team_id).compact).to eq([])
    expect(Task.pluck(:external_id)).to eq(['1', '2', '3', '4'])
  end
end
