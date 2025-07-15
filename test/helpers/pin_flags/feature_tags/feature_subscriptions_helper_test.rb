require "test_helper"

class PinFlags::FeatureTags::FeatureSubscriptionsHelperTest < ActionView::TestCase
  include PinFlags::FeatureTags::FeatureSubscriptionsHelper

  setup do
    @feature_subscription = pin_flags_feature_subscriptions(:one)
  end

  test "display_feature_subscription_table_turbo_frame_row_id returns correct id format" do
    expected_id = "feature_subscriptions_table_row_#{dom_id(@feature_subscription)}"
    assert_equal expected_id, display_feature_subscription_table_turbo_frame_row_id(@feature_subscription)
  end

  test "display_feature_subscription_table_turbo_frame_row_id includes feature_subscription prefix" do
    result = display_feature_subscription_table_turbo_frame_row_id(@feature_subscription)
    assert_match(/^feature_subscriptions_table_row_feature_subscription_/, result)
  end

  test "display_feature_subscription_table_turbo_frame_row_id includes feature_subscription id" do
    result = display_feature_subscription_table_turbo_frame_row_id(@feature_subscription)
    assert_includes result, @feature_subscription.id.to_s
  end

  test "display_feature_subscription_row_delete_confirmation returns correct message format" do
    expected_message = "Are you sure you want to delete the feature subscription for '#{@feature_subscription.feature_taggable_type}' with ID '#{@feature_subscription.feature_taggable_id}'?"
    assert_equal expected_message, display_feature_subscription_row_delete_confirmation(@feature_subscription)
  end

  test "display_feature_subscription_row_delete_confirmation includes feature_taggable_type" do
    result = display_feature_subscription_row_delete_confirmation(@feature_subscription)
    assert_includes result, @feature_subscription.feature_taggable_type
  end

  test "display_feature_subscription_row_delete_confirmation includes feature_taggable_id" do
    result = display_feature_subscription_row_delete_confirmation(@feature_subscription)
    assert_includes result, @feature_subscription.feature_taggable_id.to_s
  end

  test "display_feature_subscription_row_delete_confirmation handles special characters in taggable_type" do
    @feature_subscription.feature_taggable_type = "Test & <script>alert('xss')</script>"
    result = display_feature_subscription_row_delete_confirmation(@feature_subscription)
    expected_message = "Are you sure you want to delete the feature subscription for 'Test &amp; alert('xss')' with ID '#{@feature_subscription.feature_taggable_id}'?"
    assert_equal expected_message, result
  end

  test "display_feature_subscription_delete_button_aria_label returns correct aria label format" do
    expected_label = "Delete Feature Subscription for #{@feature_subscription.feature_taggable_type} with ID #{@feature_subscription.feature_taggable_id}"
    assert_equal expected_label, display_feature_subscription_delete_button_aria_label(@feature_subscription)
  end

  test "display_feature_subscription_delete_button_aria_label includes feature_taggable_type" do
    result = display_feature_subscription_delete_button_aria_label(@feature_subscription)
    assert_includes result, @feature_subscription.feature_taggable_type
  end

  test "display_feature_subscription_delete_button_aria_label includes feature_taggable_id" do
    result = display_feature_subscription_delete_button_aria_label(@feature_subscription)
    assert_includes result, @feature_subscription.feature_taggable_id.to_s
  end

  test "display_feature_subscription_delete_button_aria_label handles special characters in taggable_type" do
    @feature_subscription.feature_taggable_type = "Test & <script>alert('xss')</script>"
    result = display_feature_subscription_delete_button_aria_label(@feature_subscription)
    expected_label = "Delete Feature Subscription for Test &amp; alert('xss') with ID #{@feature_subscription.feature_taggable_id}"
    assert_equal expected_label, result
  end

  test "display_feature_subscription_delete_button_aria_label does not include quotes" do
    result = display_feature_subscription_delete_button_aria_label(@feature_subscription)
    assert_not_includes result, "'"
    assert_not_includes result, '"'
  end
end
