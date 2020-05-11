class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects, id: false do |t|
      t.column :project_id, 'varchar(255) PRIMARY KEY NOT NULL'
      t.string :project_name, null: false
      t.string :content, null: false
      t.string :environment, default: nil
      t.integer :price_min
      t.integer :price_max
      t.integer :min, null: false
      t.integer :max, null: false
      t.string :start_date, null: false
      t.string :end_date, default: nil
      t.string :start_time, default: nil
      t.string :end_time, default: nil
      t.string :working_place, null: false
      t.string :description, default: nil
      t.timestamps
    end
  end
end
