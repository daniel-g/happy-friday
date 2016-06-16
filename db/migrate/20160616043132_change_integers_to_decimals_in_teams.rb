class ChangeIntegersToDecimalsInTeams < Framework::Migration
  use_database :default

  def up
    change_column :teams, :timezone, "DECIMAL(6, 2) USING to_number(timezone, 'FMS9999.99')"
    change_column :teams, :dev_performance, "DECIMAL(6, 2)"
    change_column :teams, :qa_performance, "DECIMAL(6, 2)"
  end

  def down
    change_column :teams, :timezone, :string
    change_column :teams, :dev_performance, :integer
    change_column :teams, :qa_performance, :integer
  end
end
