require "test_helper"

class Api::MentionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_mentions_index_url
    assert_response :success
  end

  test "should get create" do
    get api_mentions_create_url
    assert_response :success
  end

  test "should get update" do
    get api_mentions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get api_mentions_destroy_url
    assert_response :success
  end

  test "should get active" do
    get api_mentions_active_url
    assert_response :success
  end
end
