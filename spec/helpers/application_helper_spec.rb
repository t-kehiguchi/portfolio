require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe "ページごとにタイトルを返すメソッドについて" do
    context "page_nameの指定がない場合" do
      it "「ProjectManagement」が返却されること" do
        expect(helper.full_title()).to eq "ProjectManagement"
      end
    end
    context "page_nameの指定がある(エンジニア一覧)場合" do
      it "「エンジニア一覧 | ProjectManagement」が返却されること" do
        expect(helper.full_title("エンジニア一覧")).to eq "エンジニア一覧 | ProjectManagement"
      end
    end
  end

end