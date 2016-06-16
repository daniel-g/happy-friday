require 'csv'

class Seed
  include Singleton

  def teams(team_file:, performance_file:)
    data = {}
    merge_team_generals(store: data, file: team_file)
    merge_team_performance(store: data, file: performance_file)
    create_teams(data)
  end

  def tasks(file:)
    data = {}
    merge_task_generals(store: data, file: file)
    create_tasks(data)
  end

  private

  def merge_team_generals(store:, file:)
    CSV.foreach(file, headers: :first_row) do |row|
      store[row['City']] ||= {}
      store[row['City']].merge!({
        name: row['City'],
        timezone: row['Timezone'].to_i
      })
    end
  end

  def merge_team_performance(store:, file:)
    CSV.foreach(file, headers: :first_row) do |row|
      store[row['Team']] ||= {}
      store[row['Team']].merge!({
        dev_performance: row['Developers'].to_f,
        qa_performance: row['QA'].to_f
      })
    end
  end

  def merge_task_generals(store:, file:)
    CSV.foreach(file, headers: :first_row) do |row|
      store[row['Task ID']] ||= {}
      store[row['Task ID']].merge!({
        external_id: row['Task ID'],
        dev_estimation: row['Development time'].to_i,
        qa_estimation: row['Time to test'].to_i
      })
    end
  end

  def create_teams(data)
    Team.connection_pool.with_connection { |c| c.truncate(Team.table_name) }
    data.each do |name, attributes|
      Team.create(attributes)
    end
  end

  def create_tasks(data)
    Task.connection_pool.with_connection { |c| c.truncate(Task.table_name) }
    data.each do |name, attributes|
      Task.create(attributes)
    end
  end
end
