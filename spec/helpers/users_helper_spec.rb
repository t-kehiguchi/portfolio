require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do

  describe "プルダウンを取得するためのMap" do
    it "経験年プルダウン(30年まで)が生成されること" do
      expect(helper.getExpYearMap).to eq(
        {
          0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10,
          11=>11, 12=>12, 13=>13, 14=>14, 15=>15, 16=>16, 17=>17, 18=>18, 19=>19, 20=>20,
          21=>21, 22=>22, 23=>23, 24=>24, 25=>25, 26=>26, 27=>27, 28=>28, 29=>29, 30=>30
        }
      )
    end
    it "月プルダウン(1月～12月)が生成されること" do
      expect(helper.getMonthMap).to eq(
        {
          1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10, 11=>11, 12=>12
        }
      )
    end
    it "経験月プルダウン(0ヶ月～11ヶ月)が生成されること" do
      expect(helper.getExpMonthMap).to eq(
        {
          0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10, 11=>11
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
  end

  describe "年プルダウンを取得するためのMapについて" do
    context "現在年が1958年の場合" do
      before do
        allow(Date).to receive(:today).and_return Date.new(1958,1,1)
      end
      it "1950～1958のhashが作成されること" do
        expect(helper.getYearMap).to eq(
          {
            1950=>1950, 1951=>1951, 1952=>1952, 1953=>1953, 1954=>1954, 
            1955=>1955, 1956=>1956, 1957=>1957, 1958=>1958
          }
        )
      end
    end
  end

  describe "参画可能日の年プルダウンを取得するためのMapについて" do
    context "現在日付が2020年6月8日の場合" do
      before do
        allow(Date).to receive(:today).and_return Date.new(2020,6,8)
      end
      it "2020年～2024年の5年分生成されること" do
        expect(helper.getJoinYearMap).to eq(
          {
            2020=>2020, 2021=>2021, 2022=>2022, 2023=>2023, 2024=>2024
          }
        )
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

  describe "誕生日から実年齢を取得するメソッドについて" do
    context "誕生日が1988年5月8日 かつ 現在日付が2021年6月8日の場合" do
      before do
        allow(Date).to receive(:today).and_return Date.new(2021,6,8)
      end
      it "33歳であること" do
        expect(helper.getAge('1988-05-08')).to eq 33
      end
    end
    context "誕生日が1988年5月8日 かつ 現在日付が2021年5月7日の場合" do
      before do
        allow(Date).to receive(:today).and_return Date.new(2021,5,7)
      end
      it "32歳であること" do
        expect(helper.getAge('1988-05-08')).to eq 32
      end
    end
  end

  describe "経験年数から経験月数を取得するメソッドについて" do
    it "5年8ヶ月 → 68(ヶ月)" do
      expect(helper.getTotalMonth(5,8)).to eq 68
    end
    it "0年0ヶ月 → 0(ヶ月)" do
      expect(helper.getTotalMonth(0,0)).to eq 0
    end
  end

  describe "経験月数から経験年数を取得し表示するメソッドについて" do
    it "85ヶ月 → 7年1ヶ月" do
      expect(helper.getYearAndMonth(85)).to eq "7年1ヶ月"
    end
    it "0ヶ月 → 0ヶ月" do
      expect(helper.getYearAndMonth(0)).to eq "0ヶ月"
    end
  end

  describe "経験月数から経験年数を取得し配列形式で返すメソッドについて" do
    it "85ヶ月 → [7, 1]" do
      expect(helper.getYearAndMonthArray(85)).to eq [7, 1]
    end
    it "0ヶ月 → [0, 0]" do
      expect(helper.getYearAndMonthArray(0)).to eq [0, 0]
    end
  end

  describe "スキルIDからスキル名を取得するメソッドについて" do
    context "DB(skillsテーブル)にskill_idが1のレコードが存在するという前提で" do
      it "「Windows」であること" do
        expect(helper.getSkillName(1)).to eq "Windows"
      end
    end
    context "DB(skillsテーブル)にskill_idが0のレコードが存在しないという前提で" do
      it "例外(skillテーブルからレコード取得しないでスキル名が取得できない)が発生すること" do
        expect do
          helper.getSkillName(0)
        end.to raise_error(NoMethodError)
      end
    end
  end

  describe "保持スキルがあるか否かのCSS(display,disabled)を返すメソッドについて" do
    context "保持スキルがある場合" do
      before "DBにレコードが存在しないことも前提" do
        PossessedSkill.create!(employee_number: 12345678, skill_id: 1, month: 1)
      end
      it "「display:none;, nil」が返却されること" do
        possessedSkills = PossessedSkill.where(employee_number: 12345678, skill_id: 1)
        expect(helper.isPossessedSkills(possessedSkills)).to eq ["display:none;", nil]
      end
    end
    context "保持スキルがない場合" do
      it "「nil, disabled=disabled」が返却されること" do
        expect(helper.isPossessedSkills(nil)).to eq [nil, "disabled=disabled"]
      end
    end
  end

  describe "最も経歴の長いスキル(ID)を取得するメソッド(スキルある人だけ)メソッドについて" do
    context "該当ユーザ(社員番号が「12345678」)の保持スキルのスキルが1つの場合" do
      before "DBにレコードが存在しないことも前提" do
        PossessedSkill.create!(employee_number: 12345678, skill_id: 1, month: 1)
      end
      it "skill_idが「1」が返却されること" do
        expect(helper.getMostExperientedSkillId(12345678)).to eq 1
      end
    end
    context "該当ユーザ(社員番号が「23456789」)の保持スキルのスキルが複数存在する場合" do
      before "DBにレコードが存在しないことも前提" do
        for i in 1..3
          PossessedSkill.create!(employee_number: 23456789, skill_id: i, month: i)
        end
      end
      it "経験年数(month)が最大のskill_idが「3」が返却されること" do
        expect(helper.getMostExperientedSkillId(23456789)).to eq 3
      end
    end
    context "該当ユーザ(社員番号が「34567890」)の保持スキルの経験年数(month)が全て同一の場合" do
      before "DBにレコードが存在しないことも前提" do
        for i in 1..5
          PossessedSkill.create!(employee_number: 34567890, skill_id: i, month: 3)
        end
      end
      it "最初のskill_idの「1」が返却されること" do
        expect(helper.getMostExperientedSkillId(34567890)).to eq 1
      end
    end
    context "該当ユーザ(社員番号が「12345678」)の保持スキルがない場合(DBにレコードが存在しないことも前提)" do
      it "「nil」が返却されること" do
        expect(helper.getMostExperientedSkillId(12345678)).to eq nil
      end
    end
  end

end