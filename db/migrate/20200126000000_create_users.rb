class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: false do |t|
      t.column :employee_number, 'INTEGER PRIMARY KEY NOT NULL'
      t.string :name, null: false
      t.string :name, null: false
      t.string :nearest_station, null: false
      t.string :telephone_number, null: false
      t.string :join_able_date, default: nil
      t.boolean :admin_flag, default: false
      t.string :password_digest, null: false
      t.timestamps
    end
  end
end
