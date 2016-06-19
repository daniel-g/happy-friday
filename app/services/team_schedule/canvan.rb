module TeamSchedule
  class Canvan
    # Team for the canvan
    # @!method team
    # @return [Team] the team

    # Tasks of the team in the canvan
    # @!method tasks
    # @return [ActiveRecord::Relation<Task>] the tasks
    attr_reader :team, :tasks

    # Initializes the canvan
    #
    # @param [Team] team: the team
    def initialize(team:)
      @team = team
      @tasks = team.tasks.order('tasks.id')
      @task_pointer = -1
    end

    # Takes a task from the canvan, and moves the task pointer to the next task
    #
    # @return [TeamSchedule::Task, nil] the task taken. `Nil` if no other task available
    def take_task!
      return nil if done?
      task = TeamSchedule::Task.new(
        task: next_task,
        local_time: Team::CHECK_IN_TEAM + current_load
      )
      move_pointer_forward
      task
    end

    # Tells if the canvan is finished by the team
    #
    # @return [true, false] true if the canvan is done
    def done?
      next_task.nil?
    end

    private

    # Index of the current task being worked
    # @!method task_pointer
    # @return [Integer] the index
    attr_accessor :task_pointer

    # Calculates the current load of work for the team,
    # depending on the tasks already done
    #
    # @return [Float] the total load of work done in hours
    def current_load
      return 0.0 if task_pointer < 0
      tasks[0..task_pointer].sum(&:team_cost)
    end

    # Next task being worked
    #
    # @return [Task] the task
    def next_task
      tasks[task_pointer + 1]
    end

    # Moves task pointer to the next task
    #
    # @return [Integer] index of the current task worked after the movement
    def move_pointer_forward
      self.task_pointer += 1
    end
  end
end
