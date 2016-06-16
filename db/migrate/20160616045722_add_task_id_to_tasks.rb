class AddTaskIdToTasks < Framework::Migration
  use_database :default

  def up
    add_column :tasks, :external_id, :integer
  end

  def down
    remove_column :tasks, :external_id
  end
end
