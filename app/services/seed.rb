require 'csv'

class Seed
  include Singleton

  def teams(teams_file:, performance_file:)
    data = {}
    data.deep_merge!(team_generals(file: teams_file))
    data.deep_merge!(team_performance(file: performance_file))
    create_teams(data)
  end

  def tasks(file:)
    data = {}
    data.deep_merge!(task_generals(file: file))
    create_tasks(data)
  end

  private

  def team_generals(file:)
    CSV.foreach(file, headers: :first_row).reduce({}) do |result, row|
      result[row['City']] ||= {}
      result[row['City']].merge!({
        name: row['City'],
        timezone: row['Timezone'].to_i
      })
      result
    end
  end

  def team_performance(file:)
    CSV.foreach(file, headers: :first_row).reduce({}) do |result, row|
      result[row['Team']] ||= {}
      result[row['Team']].merge!({
        dev_performance: row['Developers'].to_f,
        qa_performance: row['QA'].to_f
      })
      result
    end
  end

  def task_generals(file:)
    CSV.foreach(file, headers: :first_row).reduce({}) do |result, row|
      result[row['Task ID']] ||= {}
      result[row['Task ID']].merge!({
        external_id: row['Task ID'],
        dev_estimation: row['Development time'].to_i,
        qa_estimation: row['Time to test'].to_i
      })
      result
    end
  end

  def create_teams(data)
    truncate_table(Team)
    data.each do |name, attributes|
      Team.create(attributes)
    end
  end

  def create_tasks(data)
    truncate_table(Task)
    data.each do |name, attributes|
      Task.create(attributes)
    end
  end

  def truncate_table(model)
    model.connection_pool.with_connection { |c| c.truncate(model.table_name) }
  end
end
