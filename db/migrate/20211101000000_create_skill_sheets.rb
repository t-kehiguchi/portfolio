class CreateSkillSheets < ActiveRecord::Migration[5.1]
  def change
    create_table :skill_sheets, primary_key: %w(file_id employee_number) do |t|
      t.string :file_id
      t.integer :employee_number
      t.string :file_name, null: false
      t.timestamps
    end
  end
end