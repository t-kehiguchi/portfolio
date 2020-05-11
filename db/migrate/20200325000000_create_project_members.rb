class CreateProjectMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :project_members, id: false do |t|
      t.column :project_id, 'varchar(255) PRIMARY KEY NOT NULL'
      t.integer :employee_number, null: false
      t.string :start_date, null: false
      t.string :end_date, default: nil
      t.timestamps
    end
  end
end
