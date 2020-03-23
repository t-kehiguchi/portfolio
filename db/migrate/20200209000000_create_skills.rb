class CreateSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :skills, id: false do |t|
      t.column :skill_id, 'INTEGER PRIMARY KEY NOT NULL'
      t.string :skill_name, null: false
      t.timestamps
    end
  end
end
