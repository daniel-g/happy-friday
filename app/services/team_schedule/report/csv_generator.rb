module TeamSchedule
  class Report
    class CSVGenerator
      attr_accessor :report, :file_name

      def initialize(report: ,file_name: nil)
        if file_name.present? && !File.directory?(File.dirname(file_name))
          raise 'Directory does not exist'
        end
        @report = report
        @file_name = file_name || default_file_name
      end

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

      def headers
        ['TEAM', 'Local time', 'UTC time', 'TASK No.']
      end

      def default_file_name
        default_name = "#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
        Framework.app.root.join('reports', default_name)
      end
    end
  end
end
