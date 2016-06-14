class CreateTeams < Framework::Migration
  use_database :default

  def up
    create_table :teams do |t|
      t.string :name
      t.string :timezone
      t.integer :qa_performance
      t.integer :dev_performance
    end
  end

  def down
    drop_table :teams
  end
end
