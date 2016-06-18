class TeamSchedule
  attr_reader :team, :tasks

  def initialize(team:)
    @team = team
    @tasks = team.tasks.order('tasks.id')
    @task_pointer = -1
  end

  def take_task
    return nil unless next_task
    task = TeamSchedule::Task.new(
      team: team,
      task: next_task,
      local_time: Team::CHECK_IN_TEAM + current_load
    )
    self.task_pointer += 1
    task
  end

  private

  attr_accessor :task_pointer

  def current_load
    return 0 if task_pointer < 0
    tasks[0..task_pointer].reduce(0){|result, task| result + task.team_cost }
  end

  def next_task
    tasks[task_pointer + 1]
  end

  class Task
    attr_reader :team, :task, :local_time

    def initialize(team:, task:, local_time:)
      @team = team
      @task = task
      @local_time = local_time
    end

    def team_name
      team.name
    end

    def local_schedule
      "#{format_time(local_time)} - #{format_time(local_time + task.team_cost)}"
    end

    def utc_schedule
      "#{format_time(utc_time)} - #{format_time(utc_time + task.team_cost)}"
    end

    def task_number
      task.external_id
    end

    private

    def format_time(time_in_hours)
      total_minutes = time_in_hours * 60
      hours = total_minutes.to_i / 60
      minutes = total_minutes - hours * 60
      Time.parse("#{hours.to_i}:#{minutes.to_i}").strftime("%l:%M%P").lstrip
    end

    def utc_time
      self.local_time - team.timezone
    end
  end
end
