require "test_helper"

class PinFlags::FeatureTags::ImportsHelperTest < ActionView::TestCase
  include PinFlags::FeatureTags::ImportsHelper

  test "display_import_form_modal_id returns correct modal id" do
    expected_id = "pin-flags-import-form-modal"
    assert_equal expected_id, display_import_form_modal_id
  end

  test "display_import_form_modal_id returns consistent value" do
    first_call = display_import_form_modal_id
    second_call = display_import_form_modal_id
    assert_equal first_call, second_call
  end

  test "display_import_form_modal_id returns string" do
    result = display_import_form_modal_id
    assert_kind_of String, result
  end

  test "display_import_form_modal_id follows kebab-case naming convention" do
    result = display_import_form_modal_id
    assert_match(/^[a-z0-9-]+$/, result)
    assert_no_match(/[A-Z_\s]/, result)
  end

  test "display_import_form_modal_id is not empty" do
    result = display_import_form_modal_id
    assert_not result.empty?
  end
end
