module TeamSchedule
  class Report
    # Calculates the data to be reported for all tasks in the database,
    # sorted by the time to be worked by each team beginning at their local time.
    #
    # @return [Array<Hash>] array of data for each task, in the format TeamSchedule::Task#to_h specifies
    def data
      @data = []
      until team_schedules.all?(&:done?) do
        team_schedules.reject(&:done?).each do |team_schedule|
          @data << team_schedule.take_task!.to_h
        end
      end
      @data
    end

    # Generates a CSV with the data of the report
    #
    # @param [String] file_name: nil custom file location where to write the CSV report
    def generate_csv(file_name: nil)
      TeamSchedule::Report::CSVGenerator.new(
        report: self,
        file_name: file_name
      ).generate
    end

    private

    # List of Canvans for each team
    #
    # @return [Array<TeamSchedule::Canvan>] the array of canvans of each team
    def team_schedules
      @team_schedules ||= teams.map{|team| TeamSchedule::Canvan.new(team: team)}
    end

    # List of teams sorted by easter to wester timezone
    #
    # @return [ActiveRecord::Relation<Team>] the teams
    def teams
      @teams ||= Team.with_tasks.order('timezone DESC')
    end
  end
end
