require 'csv'

class Seed
  include Singleton

  # Seeds teams from CSV files
  #
  # @param [File] teams_file csv file with teams generals
  # @param [File] performance_file csv file with performance generals
  def teams(teams_file:, performance_file:)
    data = {}
    data.deep_merge!(team_generals(file: teams_file))
    data.deep_merge!(team_performance(file: performance_file))
    create_teams(data)
  end

  # Seeds tasks from a CSV
  #
  # @param [File] file csv file with tasks generals
  def tasks(file:)
    data = {}
    data.deep_merge!(task_generals(file: file))
    create_tasks(data)
  end

  private

  # Loads team generals from a CSV to a Hash
  #
  # @param [File] file the file
  # @return [Hash<Hash>] team generals by team name
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

  # Loads team performances from a CSV to a Hash
  #
  # @param [File] file the file
  # @return [Hash<Hash>] team performances by team name
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

  # Loads task generals from a CSV to a Hash
  #
  # @param [File] file the file
  # @return [Hash<Hash>] task generals by task ID
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

  # Seeds teams table with a data hash by team name
  #
  # @param [Hash<Hash>] data the teams data by team name
  def create_teams(data)
    truncate_table(Team)
    data.each do |name, attributes|
      Team.create(attributes)
    end
  end

  # Seeds tasks table with a data hash by task ID
  #
  # @param [Hash<Hash>] data the tasks data by task ID
  def create_tasks(data)
    truncate_table(Task)
    data.each do |name, attributes|
      Task.create(attributes)
    end
  end

  # Truncates a table, given its model
  #
  # @param [ActiveRecord::Base] model the model
  def truncate_table(model)
    model.connection_pool.with_connection { |c| c.truncate(model.table_name) }
  end
end
