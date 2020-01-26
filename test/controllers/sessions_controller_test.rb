require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get sessions_top_url
    assert_response :success
  end

end