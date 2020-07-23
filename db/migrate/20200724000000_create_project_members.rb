class CreateProjectMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :project_members, primary_key: %w(project_id employee_number) do |t|
      t.string :project_id
      t.integer :employee_number
      t.string :start_date, null: false
      t.string :end_date, default: nil
      t.timestamps
    end
  end
end
