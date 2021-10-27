# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_01_000000) do

  create_table "possessed_skills", primary_key: ["employee_number", "skill_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "employee_number", default: 0, null: false
    t.integer "skill_id", default: 0, null: false
    t.integer "month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_matchings", primary_key: ["project_id", "employee_number"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "project_id", default: "", null: false
    t.integer "employee_number", default: 0, null: false
    t.integer "created_employee_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_members", primary_key: ["project_id", "employee_number"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "project_id", default: "", null: false
    t.integer "employee_number", default: 0, null: false
    t.string "start_date", null: false
    t.string "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_must_skills", primary_key: ["project_id", "must_skill_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "project_id", default: "", null: false
    t.integer "must_skill_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_want_skills", primary_key: ["project_id", "want_skill_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "project_id", default: "", null: false
    t.integer "want_skill_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", primary_key: "project_id", id: :string, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "project_name", null: false
    t.string "content", null: false
    t.string "environment"
    t.integer "price_min"
    t.integer "price_max"
    t.integer "min", null: false
    t.integer "max", null: false
    t.string "start_date", null: false
    t.string "end_date"
    t.string "start_time"
    t.string "end_time"
    t.string "working_place", null: false
    t.string "applicant_num"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", primary_key: "skill_id", id: :integer, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "skill_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", primary_key: "employee_number", id: :integer, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "gender", null: false
    t.string "department", null: false
    t.string "birthday", null: false
    t.string "nearest_station", null: false
    t.string "telephone_number", null: false
    t.integer "price_min"
    t.integer "price_max"
    t.string "working_style", null: false
    t.string "join_able_date"
    t.string "description"
    t.boolean "admin_flag", default: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
