module TeamSchedule
  class Task
    attr_reader :team, :task, :local_time

    def initialize(task:, local_time:)
      @task = task
      @team = task.team
      @local_time = local_time
    end

    def team_name
      team.name
    end

    def local_schedule
      "#{format_hours(local_time)}" \
      " - #{format_hours(local_time + task.team_cost)}"
    end

    def utc_schedule
      "#{format_hours(utc_time)}" \
      " - #{format_hours(utc_time + task.team_cost)}"
    end

    def external_id
      task.external_id
    end

    def to_h
      {
        team_name: team_name,
        local_schedule: local_schedule,
        utc_schedule: utc_schedule,
        external_id: external_id
      }
    end

    private

    def format_hours(time_in_hours)
      total_minutes = time_in_hours * 60
      hours = total_minutes.to_i / 60
      minutes = total_minutes - hours * 60
      long_time_format = "#{hours.to_i}:#{minutes.to_i}"
      Time.parse(long_time_format).strftime("%l:%M%P").lstrip
    end

    def utc_time
      self.local_time - team.timezone
    end
  end
end
