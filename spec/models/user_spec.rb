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
    context "DBに社員番号「99999999」はエンジニアではないという前提で" do
      it "存在しない(0件である)こと" do
        expect(User.engineer.where(employee_number: 99999999).count).to eq 0
      end
    end
    context "DBに社員番号「11111111」はエンジニアであるという前提で" do
      it "存在する(1件である)こと" do
        expect(User.engineer.where(employee_number: 11111111).count).to eq 1
      end
    end
  end

end