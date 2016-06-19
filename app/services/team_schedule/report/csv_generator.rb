module TeamSchedule
  class Report
    class CSVGenerator
      attr_accessor :report, :file_name

      # Initializes the CSV generation
      #
      # @param [TeamSchedule::Report] report: the report where from get the data
      # @param [String] file_name: nil path to file where to put the CSV generated
      def initialize(report: ,file_name: nil)
        if file_name.present? && !File.directory?(File.dirname(file_name))
          raise 'Directory does not exist'
        end
        @report = report
        @file_name = file_name || default_file_name
      end

      # Generates the CSV file
      #
      def generate
        CSV.open(file_name, 'wb', write_headers: true, headers: headers) do |csv|
          report.data.each do |task|
            csv << [
              task[:team_name],
              task[:local_schedule],
              task[:utc_schedule],
              task[:external_id]
            ]
          end
        end
      end

      private

      # Headers for the CSV report
      #
      # @return [Array<String>] the headers
      def headers
        ['TEAM', 'Local time', 'UTC time', 'TASK No.']
      end

      # Default file name if not specified in the initializer
      #
      # @return [String] app_root/reports/<timestamp>.csv
      def default_file_name
        default_name = "#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
        Framework.app.root.join('reports', default_name)
      end
    end
  end
end
