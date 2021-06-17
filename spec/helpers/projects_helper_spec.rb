require 'rails_helper'

RSpec.describe ProjectsHelper, type: :helper do

  describe "単価を金額表示(3桁区切り)にするメソッドについて" do
    context "単価がある(1000000円)場合" do
      it "「1,000,000円」が返却されること" do
        expect(helper.getPriceDisplay(1000000)).to eq "1,000,000円"
      end
    end
    context "単価がない(空文字 or nil)場合" do
      it "空文字が返却されること" do
        expect(helper.getPriceDisplay("")).to eq ""
        expect(helper.getPriceDisplay(nil)).to eq ""
      end
    end
  end

  describe "スキルIDからスキル名を取得するメソッドについて" do
    context "DB(skillsテーブル)に存在するスキルIDを指定する場合" do
      before "skill_idが1のレコードが存在するという前提で(仮に存在しない場合は追加する)" do
        unless Skill.where(skill_id: 1).present?
          Skill.create!(skill_id: 1, skill_name: "Windows")
        end
      end
      it "「Windows」であること" do
        expect(helper.getSkillName(1)).to eq "Windows"
      end
    end
    context "DB(skillsテーブル)に存在しないスキルIDを指定する場合" do
      before "skill_idが0のレコードが存在しないという前提で(仮に存在する場合は削除する)" do
        record = Skill.where(skill_id: 0)
        record.destroy_all if record.present?
      end
      it "例外(skillテーブルからレコード取得しないでスキル名が取得できない)が発生すること" do
        expect do
          helper.getSkillName(0)
        end.to raise_error(NoMethodError)
      end
    end
  end

  describe "社員番号からユーザー情報を取得するメソッドについて" do
    context "DB(Userテーブル)に該当のemployee_numberが存在する場合" do
      before "employee_numberが11111111(樋口健児)のレコードが存在するという前提で(存在しない場合は追加する)" do
        unless User.where(employee_number: 11111111).present?
          User.create!(employee_number: 11111111, password: "password", password_confirmation: "password",
                       name: "樋口健児", department: "システム開発", birthday: "1988-05-08",
                       nearest_station: "練馬駅", telephone_number: "090-5496-0563", join_able_date: "2020-04-01")
        end
      end
      it "名前が「樋口健児」であること" do
        expect(helper.getUser(11111111).name).to eq "樋口健児"
      end
    end
    context "DB(Userテーブル)に該当のemployee_numberが存在しない場合" do
      before "employee_numberが12345678のレコードが存在しないという前提で(仮に存在する場合は削除する)" do
        record = User.where(employee_number: 12345678)
        record.destroy_all if record.present?
      end
      it "レコードが存在しないこと(例外が発生すること)" do
        expect do
          helper.getUser(12345678)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "金額の幅を表示するメソッドについて" do
    it "400000円～1000000円までの範囲のプルダウンが生成されること" do
      expect(helper.getPriceDsp).to eq(
        {
          "<= 400000"=>"～ 400,000円",
          "BETWEEN 400000 AND 500000"=>"400,000円 ～ 500,000円",
          "BETWEEN 500000 AND 600000"=>"500,000円 ～ 600,000円",
          "BETWEEN 600000 AND 700000"=>"600,000円 ～ 700,000円",
          "BETWEEN 700000 AND 800000"=>"700,000円 ～ 800,000円",
          "BETWEEN 800000 AND 900000"=>"800,000円 ～ 900,000円",
          "BETWEEN 900000 AND 1000000"=>"900,000円 ～ 1,000,000円",
          ">= 1000000"=>"1,000,000円 ～"
        }
      )
    end
  end

  describe "案件開始(終了予定)日の年プルダウンを取得するためのMap" do
    context "日付が指定ある前提で(対象年は2021年)" do
      it "2019～2023年までのプルダウンが生成されること" do
        expect(helper.getStartOrEndYearMap("2021/06/18")).to eq(
          {
            2019=>2019, 2020=>2020, 2021=>2021, 2022=>2022, 2023=>2023
          }
        )
      end
    end
    context "日付指定なし かつ projectIdが存在する場合" do
      before "以下のProjectテーブルのレコードがDBに存在しない前提で(仮に存在した場合はReplace)" do
        record = Project.where(project_id: "20210618-01")
        record.destroy_all if record.present?
        Project.create!(project_id: "20210618-01", project_name: "A", content: "B", 
                        min: 500000, max: 1000000, start_date: "2021-06-01", 
                        working_place: "C")
      end
      it "2021～2025年までのプルダウンが生成されること" do
        expect(helper.getStartOrEndYearMap("", "20210618-01")).to eq(
          {
            2021=>2021, 2022=>2022, 2023=>2023, 2024=>2024, 2025=>2025
          }
        )
      end
    end
    context "日付指定なし かつ projectIdが存在しない場合" do
      before "現在日付が2020年6月18日であることを前提で" do
        allow(Date).to receive(:today).and_return Date.new(2020,6,18)
      end
      it "2020～2024年までのプルダウンが生成されること" do
        expect(helper.getStartOrEndYearMap("")).to eq(
          {
            2020=>2020, 2021=>2021, 2022=>2022, 2023=>2023, 2024=>2024
          }
        )
      end
    end
  end

  describe "プルダウンを取得するためのMap" do
    it "月プルダウン(1月～12月)が生成されること" do
      expect(helper.getMonthMap).to eq(
        {
          1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10, 11=>11, 12=>12
        }
      )
    end
    it "日プルダウン(1日～31日)が生成されること" do
      expect(helper.getDayMap).to eq(
        {
          1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10,
          11=>11, 12=>12, 13=>13, 14=>14, 15=>15, 16=>16, 17=>17, 18=>18, 19=>19, 20=>20,
          21=>21, 22=>22, 23=>23, 24=>24, 25=>25, 26=>26, 27=>27, 28=>28, 29=>29, 30=>30, 31=>31
        }
      )
    end
    it "時プルダウン(0時～23時)が生成されること" do
      expect(helper.getHourMap).to eq(
        {
          0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9,
          10=>10, 11=>11, 12=>12, 13=>13, 14=>14, 15=>15, 16=>16, 17=>17, 18=>18, 19=>19,
          20=>20, 21=>21, 22=>22, 23=>23
        }
      )
    end
    it "分プルダウン(0分～59分まで15分刻み)が生成されること" do
      expect(helper.getMinutesMap).to eq(
        {
          0=>"00", 15=>"15", 30=>"30", 45=>"45"
        }
      )
    end
  end

  describe "2項目(時間)から～番目を指定して取得するメソッドについて" do
    context "時間(05:08)から1番目(first)を指定する場合" do
      it "5が取得されること" do
        expect(helper.getTwo("05:08", 'first')).to eq 5
      end
    end
    context "時間(05:08)から2番目(second)を指定する場合" do
      it "「08」が取得されること" do
        expect(helper.getTwo("05:08", 'second')).to eq 8
      end
    end
    context "空文字列 or nilから1番目(first)を指定する場合" do
      it "空が返却されること" do
        expect(helper.getTwo("", 'first').blank?).to eq true
        expect(helper.getTwo(nil, 'first').blank?).to eq true
      end
    end
    context "時間(05:08)から1番目～2番目以外を指定する場合" do
      it "空が返却されること" do
        expect(helper.getTwo("05:08", 'third').blank?).to eq true
      end
    end
    context "フォーマットが異なる時間(05;08)から2番目(second)を指定する場合" do
      it "nilが返却されること(～番目関係なく)" do
        expect(helper.getThree("05;08", 'second')).to eq nil
      end
    end
  end

  describe "3項目(年月日や電話番号)から～番目を指定して取得するメソッドについて" do
    context "年月日(1988年5月8日)から1番目(first)を指定する場合" do
      it "1988が取得されること" do
        expect(helper.getThree("1988-05-08", 'first')).to eq "1988"
      end
    end
    context "電話番号(0123-456-789)から2番目(second)を指定する場合" do
      it "456が取得されること" do
        expect(helper.getThree("0123-456-789", 'second')).to eq "456"
      end
    end
    context "年月日(1988年5月8日)から3番目(third)を指定する場合" do
      it "08が取得されること" do
        expect(helper.getThree("1988-05-08", 'third')).to eq "08"
      end
    end
    context "空文字列 or nilから1番目(first)を指定する場合" do
      it "空が返却されること" do
        expect(helper.getThree("", 'first').blank?).to eq true
        expect(helper.getThree(nil, 'first').blank?).to eq true
      end
    end
    context "電話番号(0123-456-789)から空文字列 or nil番目を指定する場合" do
      it "空が返却されること" do
        expect(helper.getThree("0123-456-789", '').blank?).to eq true
        expect(helper.getThree("0123-456-789", nil).blank?).to eq true
      end
    end
    context "電話番号(0123-456-789)から1番目～3番目以外を指定する場合" do
      it "空が返却されること" do
        expect(helper.getThree("1988-05-08", 'fifth').blank?).to eq true
      end
    end
    context "フォーマットが異なる年月日(1988/05/08)から2番目(second)を指定する場合" do
      it "nilが返却されること(～番目関係なく)" do
        expect(helper.getThree("1988/05/08", 'second')).to eq nil
      end
    end
  end

end