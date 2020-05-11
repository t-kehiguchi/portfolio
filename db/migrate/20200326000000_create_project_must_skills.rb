class CreateProjectMustSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :project_must_skills, primary_key: %w(project_id must_skill_id) do |t|
      t.string :project_id
      t.integer :must_skill_id
      t.timestamps
    end
  end
end
