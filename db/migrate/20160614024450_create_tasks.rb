class CreateTasks < Framework::Migration
  use_database :default

  def up
    create_table :tasks do |t|
      t.integer :qa_estimation, default: 0
      t.integer :dev_estimation, default: 0
      t.references :team
    end
  end

  def down
    drop_table :tasks
  end
end
