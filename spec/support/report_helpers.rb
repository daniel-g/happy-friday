module ReportHelpers
  def to_report_data_hash(data_array)
    data_headers = [:team_name, :local_schedule, :utc_schedule, :external_id]
    data_headers.zip(data_array).to_h
  end
end
