class CreateProjectWantSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :project_want_skills, primary_key: %w(project_id want_skill_id) do |t|
      t.string :project_id
      t.integer :want_skill_id
      t.timestamps
    end
  end
end
