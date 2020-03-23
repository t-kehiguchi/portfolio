class CreatePossessedSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :possessed_skills, primary_key: %w(employee_number skill_id) do |t|
      t.integer :employee_number
      t.integer :skill_id
      t.integer :month, null: false
      t.timestamps
    end
  end
end
