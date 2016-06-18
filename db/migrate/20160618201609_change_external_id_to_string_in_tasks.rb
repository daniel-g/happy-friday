class ChangeExternalIdToStringInTasks < Framework::Migration
  use_database :default

  def up
    change_column :tasks, :external_id, :string
  end

  def down
    change_column :tasks, :external_id, "integer USING CAST(external_id AS INT)"
  end
end
