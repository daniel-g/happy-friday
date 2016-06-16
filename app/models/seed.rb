require 'csv'

class Seed
  include Singleton

  def teams(team_file:, performance_file:)
    teams_data = {}
    merge_team_generals(store: teams_data, file: team_file)
    merge_team_performance(store: teams_data, file: performance_file)
    create_teams(teams_data)
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

  def create_teams(teams_data)
    Team.truncate_table
    teams_data.each do |name, attributes|
      Team.create(attributes)
    end
  end
end
