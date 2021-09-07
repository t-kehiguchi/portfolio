class CreateProjectMatchings < ActiveRecord::Migration[5.1]
  def change
    create_table :project_matchings, primary_key: %w(project_id employee_number) do |t|
      t.string :project_id
      t.integer :employee_number
      t.integer :created_employee_number
      t.timestamps
    end
  end
end
