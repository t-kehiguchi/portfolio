require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  describe "引数に渡されたユーザーでログインするメソッドについて" do
    it "正常にセッション情報に社員番号が格納されること" do
      user = User.new(employee_number: 12345678)
      helper.log_in(user)
      expect(session[:employee_number]).to eq 12345678
    end
  end

  describe "現在のユーザーをログアウトするメソッドについて" do
    context "ログアウト前にログインされている状態で" do
      before do
        user = User.new(employee_number: 12345678)
        helper.log_in(user)
      end
      it "ログアウト後にセッション情報がnilとなること" do
        helper.log_out
        expect(session[:employee_number]).to eq nil
      end
    end
  end

  describe "現在ログイン中のユーザーを返す (ただし、いる場合のみ)メソッドについて" do
    before "DB(Userテーブル)に存在している社員番号「11111111」がログインしている前提で" do
      user = User.new(employee_number: 11111111)
      helper.log_in(user)
    end
    it "ログインユーザーは現在社員番号「11111111」のユーザーであること" do
      expect(helper.current_user.employee_number).to eq 11111111
    end
    it "ログアウト後にcurrent_userはnilであること" do
      helper.log_out
      expect(helper.current_user).to eq nil
    end
  end

  describe "ユーザーがログインしていればtrue、その他ならfalseを返すメソッドについて" do
    context "DB(Userテーブル)に存在している社員番号のユーザーがログイン中の場合" do
      before do
        user = User.new(employee_number: 11111111)
        helper.log_in(user)
      end
      it "trueが返却されること" do
        expect(helper.logged_in?).to eq true
      end
    end
    context "未ログイン(DB(Userテーブル)に存在しないユーザーでログイン)の場合" do
      before do
        user = User.new(employee_number: 12345678)
        helper.log_in(user)
      end
      it "falseが返却されること" do
        expect(helper.logged_in?).to eq false
      end
    end
    context "ログイン直後にログアウトした場合" do
      before do
        user = User.new(employee_number: 11111111)
        helper.log_in(user)
        helper.log_out
      end
      it "falseが返却されること" do
        expect(helper.logged_in?).to eq false
      end
    end
  end

end