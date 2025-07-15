require "test_helper"

class PinFlags::ApplicationHelperTest < ActionView::TestCase
  include PinFlags::ApplicationHelper

  test "flash_class returns correct class for notice" do
    assert_equal "is-success", flash_class("notice")
    assert_equal "is-success", flash_class(:notice)
  end

  test "flash_class returns correct class for success" do
    assert_equal "is-success", flash_class("success")
    assert_equal "is-success", flash_class(:success)
  end

  test "flash_class returns correct class for alert" do
    assert_equal "is-danger", flash_class("alert")
    assert_equal "is-danger", flash_class(:alert)
  end

  test "flash_class returns correct class for error" do
    assert_equal "is-danger", flash_class("error")
    assert_equal "is-danger", flash_class(:error)
  end

  test "flash_class returns correct class for warning" do
    assert_equal "is-warning", flash_class("warning")
    assert_equal "is-warning", flash_class(:warning)
  end

  test "flash_class returns default class for unknown type" do
    assert_equal "is-info", flash_class("unknown")
    assert_equal "is-info", flash_class(:unknown)
    assert_equal "is-info", flash_class(nil)
    assert_equal "is-info", flash_class("")
  end

  test "page_title returns content_for title when present" do
    content_for :title, "Custom Title"
    assert_equal "Custom Title", page_title
  end

  test "page_title returns default Dashboard when no title set" do
    assert_equal "Dashboard", page_title
  end

  test "page_title returns Dashboard when title is empty" do
    content_for :title, ""
    assert_equal "Dashboard", page_title
  end
end
