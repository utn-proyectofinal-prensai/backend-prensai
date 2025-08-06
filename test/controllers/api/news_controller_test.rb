require "test_helper"

class Api::NewsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_news_index_url
    assert_response :success
  end

  test "should get show" do
    get api_news_show_url
    assert_response :success
  end

  test "should get import" do
    get api_news_import_url
    assert_response :success
  end

  test "should get metrics" do
    get api_news_metrics_url
    assert_response :success
  end
end
