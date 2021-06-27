require 'rails_helper'

RSpec.describe User, type: :model do

  describe "enumのadminについて" do
    it "管理者であること" do
      user = User.new(admin_flag: true)
      expect(user.admin_flag).to eq User.admins['admin']
    end
    it "一般ユーザー(エンジニア)であること" do
      user = User.new(admin_flag: false)
      expect(user.admin_flag).to eq User.admins['general']
    end
  end

  describe "scopeのengineerについて" do
    context "エンジニアではない場合" do
      before "DBに社員番号「99999999」はエンジニアではないという前提で(仮に存在した場合はReplace(admin_flagが変更されていることも考慮して))" do
        record = User.where(employee_number: 99999999)
        record.destroy_all if record.present?
        User.create!(employee_number: 99999999, password: "password", password_confirmation: "password",
                     name: "A", department: "B", birthday: "2021-06-28",
                     nearest_station: "C", telephone_number: "012-3456-7890", join_able_date: nil,
                     admin_flag: User.admins['admin'])
      end
      it "存在しない(0件である)こと" do
        expect(User.engineer.where(employee_number: 99999999).count).to eq 0
      end
    end
    context "エンジニアではある場合" do
      before "DBに社員番号「11111111」はエンジニアであるという前提で(仮に存在した場合はReplace(admin_flagが変更されていることも考慮して)" do
        record = User.where(employee_number: 11111111)
        record.destroy_all if record.present?
        User.create!(employee_number: 11111111, password: "password", password_confirmation: "password",
                     name: "A", department: "B", birthday: "2021-06-28",
                     nearest_station: "C", telephone_number: "012-3456-7890", join_able_date: "2021-06-28",
                     admin_flag: User.admins['general'])
      end
      it "存在する(1件である)こと" do
        expect(User.engineer.where(employee_number: 11111111).count).to eq 1
      end
    end
  end

end