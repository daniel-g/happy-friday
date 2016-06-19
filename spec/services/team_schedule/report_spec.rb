require 'spec_helper'

describe TeamSchedule::Report do
  subject(:report) { TeamSchedule::Report.new }

  context 'one team in utc' do
    let!(:team) { FactoryGirl.create(:team) }
    let!(:task_1) { FactoryGirl.create(:task, team: team) }
    let!(:task_2) { FactoryGirl.create(:task, team: team) }

    subject(:data) { report.data }

    it 'generates the data for a report of tasks sorted by hour of work' do
      expect(data.size).to eq(Task.count)
      expect(data[0]).to eq(to_report_data_hash([team.name, '9:00am - 11:00am', '9:00am - 11:00am', task_1.external_id]))
      expect(data[1]).to eq(to_report_data_hash([team.name, '11:00am - 1:00pm', '11:00am - 1:00pm', task_2.external_id]))
    end
  end

  context 'one team in +3' do
    let!(:team) { FactoryGirl.create(:team, timezone: 3) }
    let!(:task_1) { FactoryGirl.create(:task, team: team) }
    let!(:task_2) { FactoryGirl.create(:task, team: team) }

    subject(:data) { report.data }

    it 'generates the data for a report of tasks sorted by hour of work' do
      expect(data[0]).to eq(to_report_data_hash([team.name, '9:00am - 11:00am', '6:00am - 8:00am', task_1.external_id]))
      expect(data[1]).to eq(to_report_data_hash([team.name, '11:00am - 1:00pm', '8:00am - 10:00am', task_2.external_id]))
    end
  end

  context 'many teams in different timezones' do
    let!(:moscow) { FactoryGirl.create(:team, timezone: 3) }
    let!(:london) { FactoryGirl.create(:team, timezone: 0) }
    let!(:moscow_1) { FactoryGirl.create(:task, team: moscow) }
    let!(:moscow_2) { FactoryGirl.create(:task, team: moscow) }
    let!(:london_1) { FactoryGirl.create(:task, team: london) }
    let!(:london_2) { FactoryGirl.create(:task, team: london) }

    subject(:data) { report.data }

    it 'generates the data for a report of tasks sorted by hour of work' do
      expect(data.size).to eq(Task.count)
      expect(data[0]).to eq(to_report_data_hash([moscow.name, '9:00am - 11:00am', '6:00am - 8:00am', moscow_1.external_id]))
      expect(data[1]).to eq(to_report_data_hash([london.name, '9:00am - 11:00am', '9:00am - 11:00am', london_1.external_id]))
      expect(data[2]).to eq(to_report_data_hash([moscow.name, '11:00am - 1:00pm', '8:00am - 10:00am', moscow_2.external_id]))
      expect(data[3]).to eq(to_report_data_hash([london.name, '11:00am - 1:00pm', '11:00am - 1:00pm', london_2.external_id]))
    end
  end

  context 'many teams in different timezones: hard case' do
    let!(:moscow){ FactoryGirl.create(:team, name: 'Moscow', timezone: 3, dev_performance: 1, qa_performance: 0.5) }
    let!(:zagreb){ FactoryGirl.create(:team, name: 'Zagreb', timezone: 2, dev_performance: 0.25, qa_performance: 0.25) }
    let!(:london){ FactoryGirl.create(:team, name: 'London', timezone: 0, dev_performance: 0.5, qa_performance: 1) }

    let!(:moscow_1) { FactoryGirl.create(:task, team: moscow, dev_estimation: 2, qa_estimation: 1, external_id: 1) }
    let!(:moscow_2) { FactoryGirl.create(:task, team: moscow, dev_estimation: 2, qa_estimation: 2, external_id: 4) }
    let!(:london_1) { FactoryGirl.create(:task, team: london, dev_estimation: 2, qa_estimation: 1, external_id: 2) }
    let!(:london_2) { FactoryGirl.create(:task, team: london, dev_estimation: 1, qa_estimation: 2, external_id: 3) }

    subject(:data) { report.data }

    it 'generates the data for a report of tasks sorted by hour of work' do
      expect(data.size).to eq(Task.count)
      expect(data[0]).to eq(to_report_data_hash([moscow.name, '9:00am - 1:00pm', '6:00am - 10:00am', moscow_1.external_id]))
      expect(data[1]).to eq(to_report_data_hash([london.name, '9:00am - 2:00pm', '9:00am - 2:00pm', london_1.external_id]))
      expect(data[2]).to eq(to_report_data_hash([moscow.name, '1:00pm - 7:00pm', '10:00am - 4:00pm', moscow_2.external_id]))
      expect(data[3]).to eq(to_report_data_hash([london.name, '2:00pm - 6:00pm', '2:00pm - 6:00pm', london_2.external_id]))
    end
  end

  describe 'CSV generation' do
    it 'generates the CSV of the data generated' do
      allow_any_instance_of(TeamSchedule::Report::CSVGenerator).to receive(:generate).and_return('CSV!')
      expect(TeamSchedule::Report::CSVGenerator).to(
        receive(:new)
          .with(report: report, file_name: nil)
          .and_call_original
      )
      expect(report.generate_csv).to eq('CSV!')
    end

    it 'raises exception if the directory of the file specified does not exist' do
      missing_path = Framework.app.root.join('spec/fixtures/missing_folder/report.csv')
      expect{ TeamSchedule::Report.new.generate_csv(file_name: missing_path) }.to raise_error(RuntimeError)
    end
  end
end
