require 'spec_helper'

describe Report::CSVGenerator do
  let(:data) {[
    ['Moscow', '9:00am - 11:00am', '9:00am - 11:00am', '1'],
    ['Zagreb', '9:00am - 11:00am', '9:00am - 11:00am', '2'],
    ['London', '9:00am - 11:00am', '9:00am - 11:00am', '3']
  ]}

  let(:file_name){ Framework.root.join('spec', 'reports', 'report.csv') }
  let(:report) { double(:report, data: data) }

  subject(:csv_generator) { Report::CSVGenerator.new(report: report, file_name: file_name) }

  it 'generates a csv file with the data of a report' do
    allow(report).to receive(:data).and_return(data.map{|d| to_report_data_hash(d) })
    csv_generator.generate
    csv = CSV.read(file_name)
    expect(csv.size - 1).to eq(data.count)
    expect(csv[1..-1]).to match_array(data)
    File.delete(file_name)
  end
end
