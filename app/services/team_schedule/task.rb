module TeamSchedule
  class Task
    # Team of the task
    # @!method team
    # @return [Team] the team

    # Task from where to calculate the schedule
    # @!method task
    # @return [Task] the task

    # Local time when the task will be begun
    # @!method local_time
    # @return [Float] local time of the team in hours
    attr_reader :team, :task, :local_time

    # Initializes a team schedule task
    #
    # @param [Task] task: the task
    # @param [Float] local_time: local time of the team in hours
    def initialize(task:, local_time:)
      @task = task
      @team = task.team
      @local_time = local_time
    end

    # Name of the team
    #
    # @return [String] the name of the team
    def team_name
      team.name
    end

    # Calculates local schedule when the task will begin and end
    #
    # @return [String] the local schedule in 12 hour format
    def local_schedule
      "#{format_hours(local_time)}" \
      " - #{format_hours(local_time + task.team_cost)}"
    end

    # Calculates schedule in UTC when the task will begin and end
    #
    # @return [String] the schedule in UTC in 12 hour format
    def utc_schedule
      "#{format_hours(utc_time)}" \
      " - #{format_hours(utc_time + task.team_cost)}"
    end

    # External ID of the task
    #
    # @return [String] the external id
    def external_id
      task.external_id
    end

    # Converts the scheduled task to a hash
    #
    # @return [Hash]
    def to_h
      {
        team_name: team_name,
        local_schedule: local_schedule,
        utc_schedule: utc_schedule,
        external_id: external_id
      }
    end

    private

    # Formats an hour into 12 hour format
    #
    # @param [Float] time_in_hours hours in number
    # @return [String] string representation of the hours in 12 hour format
    def format_hours(time_in_hours)
      total_minutes = time_in_hours * 60
      hours = total_minutes.to_i / 60
      minutes = total_minutes - hours * 60
      long_time_format = "#{hours.to_i}:#{minutes.to_i}"
      Time.parse(long_time_format).strftime("%l:%M%P").lstrip
    end

    # Calculates the hour in UTC when the task will begin
    #
    # @return [Float] hour of the day when the task will begin
    def utc_time
      self.local_time - team.timezone
    end
  end
end
