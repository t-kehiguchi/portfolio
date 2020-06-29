class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

    ## 日付比較メソッド(引数は文字列)
    def compareDate(date1, date2)
      ## 日付の引き算を返す(正ならdate2、負ならdate1が新しい日付、0なら同一日付)
      (Date.parse(date2) - Date.parse(date1)).to_i
    end

end
