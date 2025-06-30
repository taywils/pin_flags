require "test_helper"

module PinFlags
  class FeatureTagsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get feature_tags_index_url
      assert_response :success
    end

    test "should get show" do
      get feature_tags_show_url
      assert_response :success
    end

    test "should get new" do
      get feature_tags_new_url
      assert_response :success
    end

    test "should get create" do
      get feature_tags_create_url
      assert_response :success
    end

    test "should get update" do
      get feature_tags_update_url
      assert_response :success
    end

    test "should get destroy" do
      get feature_tags_destroy_url
      assert_response :success
    end
  end
end
