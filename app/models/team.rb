class Team < ActiveRecord::Base
  def self.truncate_table
    self.connection_pool.with_connection { |c| c.truncate(table_name) }
  end
end
