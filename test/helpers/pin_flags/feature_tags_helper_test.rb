require "test_helper"

class PinFlags::FeatureTagsHelperTest < ActionView::TestCase
  include PinFlags::FeatureTagsHelper

  setup do
    @feature_tag = pin_flags_feature_tags(:live_feature)
  end

  test "display_feature_tag_table_turbo_frame_row_id returns correct id format" do
    expected_id = "feature_tags_table_row_#{dom_id(@feature_tag)}"
    assert_equal expected_id, display_feature_tag_table_turbo_frame_row_id(@feature_tag)
  end

  test "display_feature_tag_table_turbo_frame_row_id includes feature_tag prefix" do
    result = display_feature_tag_table_turbo_frame_row_id(@feature_tag)
    assert_match(/^feature_tags_table_row_feature_tag_/, result)
  end

  test "display_feature_tag_table_turbo_frame_row_id includes feature_tag id" do
    result = display_feature_tag_table_turbo_frame_row_id(@feature_tag)
    assert_includes result, @feature_tag.id.to_s
  end

  test "display_feature_tag_row_delete_confirmation returns correct message format" do
    expected_message = "Are you sure you want to delete the feature tag '#{@feature_tag.name}'?"
    assert_equal expected_message, display_feature_tag_row_delete_confirmation(@feature_tag)
  end

  test "display_feature_tag_row_delete_confirmation includes feature tag name" do
    result = display_feature_tag_row_delete_confirmation(@feature_tag)
    assert_includes result, @feature_tag.name
  end

  test "display_feature_tag_row_delete_confirmation handles feature tag with quotes in name" do
    @feature_tag.name = "Test's 'quoted' name"
    result = display_feature_tag_row_delete_confirmation(@feature_tag)
    normalized_name = PinFlags::FeatureTag.normalize_tag_name(@feature_tag.name)
    expected_message = "Are you sure you want to delete the feature tag '#{normalized_name}'?"
    assert_equal expected_message, result
  end

  test "display_feature_tag_row_delete_confirmation handles feature tag with special characters" do
    @feature_tag.name = "Test & <script>alert('xss')</script>"
    normalized_name = PinFlags::FeatureTag.normalize_tag_name(@feature_tag.name)
    result = display_feature_tag_row_delete_confirmation(@feature_tag)
    expected_message = "Are you sure you want to delete the feature tag '#{normalized_name}'?"
    assert_equal expected_message, result
  end

  test "pin_flags_logo returns SVG content" do
    result = pin_flags_logo
    assert_includes result, "<svg"
    assert_includes result, ">Pin</tspan>"
    assert_includes result, ">Flags</tspan>"
  end

  test "pin_flags_logo returns html safe string" do
    result = pin_flags_logo
    assert_predicate result, :html_safe?
  end

  test "pin_flags_logo uses default dimensions" do
    result = pin_flags_logo
    assert_includes result, 'width="260"'
    assert_includes result, 'height="85"'
  end

  test "pin_flags_logo accepts custom width and height" do
    result = pin_flags_logo(width: 520, height: 170)
    assert_includes result, 'width="520"'
    assert_includes result, 'height="170"'
  end
end
