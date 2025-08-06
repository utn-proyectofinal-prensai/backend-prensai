require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get api_users_login_url
    assert_response :success
  end

  test "should get logout" do
    get api_users_logout_url
    assert_response :success
  end

  test "should get me" do
    get api_users_me_url
    assert_response :success
  end
end
