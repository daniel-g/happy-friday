class ChangeTypeOfEstimationsInTasks < Framework::Migration
  use_database :default

  def up
    change_column :tasks, :dev_estimation, "DECIMAL(6, 2)"
    change_column :tasks, :qa_estimation, "DECIMAL(6, 2)"
  end

  def down
    change_column :tasks, :dev_estimation, :integer
    change_column :tasks, :qa_estimation, :integer
  end
end
