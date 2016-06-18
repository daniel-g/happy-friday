require 'spec_helper'

describe Report do
  let(:file_name){ Framework.root.join('spec', 'reports', 'report.csv') }

  subject(:report) { Report.new(file_name: file_name) }

  after do
    File.delete(file_name) if File.exist?(file_name)
  end

  context 'one team in utc' do
    let!(:team) { FactoryGirl.create(:team) }
    let!(:task_1) { FactoryGirl.create(:task, team: team) }
    let!(:task_2) { FactoryGirl.create(:task, team: team) }

    it 'generates a report of tasks sorted by hour of work' do
      report.generate!
      csv = CSV.read(file_name)
      expect(csv.size - 1).to eq(Task.count)
      expect(csv[1]).to match_array([team.name, '9:00am - 11:00am', '9:00am - 11:00am', task_1.external_id])
      expect(csv[2]).to match_array([team.name, '11:00am - 1:00pm', '11:00am - 1:00pm', task_2.external_id])
    end
  end

  context 'one team in +3' do
    let!(:team) { FactoryGirl.create(:team, timezone: 3) }
    let!(:task_1) { FactoryGirl.create(:task, team: team) }
    let!(:task_2) { FactoryGirl.create(:task, team: team) }

    it 'generates a report of tasks sorted by hour of work' do
      report.generate!
      csv = CSV.read(file_name)
      expect(csv[1]).to match_array([team.name, '9:00am - 11:00am', '6:00am - 8:00am', task_1.external_id])
      expect(csv[2]).to match_array([team.name, '11:00am - 1:00pm', '8:00am - 10:00am', task_2.external_id])
    end
  end

  context 'many teams in different timezones' do
    let!(:moscow) { FactoryGirl.create(:team, timezone: 3) }
    let!(:london) { FactoryGirl.create(:team, timezone: 0) }
    let!(:moscow_1) { FactoryGirl.create(:task, team: moscow) }
    let!(:moscow_2) { FactoryGirl.create(:task, team: moscow) }
    let!(:london_1) { FactoryGirl.create(:task, team: london) }
    let!(:london_2) { FactoryGirl.create(:task, team: london) }

    it 'generates a report of tasks sorted by hour of work' do
      report.generate!
      csv = CSV.read(file_name)
      expect(csv.size - 1).to eq(Task.count)
      expect(csv[1]).to match_array([moscow.name, '9:00am - 11:00am', '6:00am - 8:00am', moscow_1.external_id])
      expect(csv[2]).to match_array([london.name, '9:00am - 11:00am', '9:00am - 11:00am', london_1.external_id])
      expect(csv[3]).to match_array([moscow.name, '11:00am - 1:00pm', '8:00am - 10:00am', moscow_2.external_id])
      expect(csv[4]).to match_array([london.name, '11:00am - 1:00pm', '11:00am - 1:00pm', london_2.external_id])
    end
  end

  it 'raises exception if the directory of the file specified does not exist' do
    missing_path = Framework.app.root.join('spec/fixtures/missing_folder/report.csv')
    expect{ Report.new(file_name: missing_path) }.to raise_error(RuntimeError)
  end
end
