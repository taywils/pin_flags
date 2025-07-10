require "test_helper"

class PinFlags::PageTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing records first
    PinFlags::FeatureTag.destroy_all

    # Create some test records
    5.times do |i|
      PinFlags::FeatureTag.create!(
        name: "feature_#{i}",
        enabled: true
      )
    end

    # Set relation after creating records
    @relation = PinFlags::FeatureTag.all
  end

  test "should initialize with default values" do
    page = PinFlags::Page.new(@relation)

    assert_equal 1, page.index
    assert_equal PinFlags::Page::DEFAULT_PAGE_SIZE, page.page_size
    assert_not_nil page.records
  end

  test "should initialize with custom page and page_size" do
    page = PinFlags::Page.new(@relation, page: 2, page_size: 3)

    assert_equal 2, page.index
    assert_equal 3, page.page_size
  end

  test "should enforce minimum page index of 1" do
    page = PinFlags::Page.new(@relation, page: 0)
    assert_equal 1, page.index

    page = PinFlags::Page.new(@relation, page: -5)
    assert_equal 1, page.index
  end

  test "records should return limited and offset results" do
    page = PinFlags::Page.new(@relation, page: 1, page_size: 3)
    records = page.records

    assert_equal 3, records.count
    assert_equal 3, records.limit_value
    assert_equal 0, records.offset_value
  end

  test "records should apply correct offset for subsequent pages" do
    page = PinFlags::Page.new(@relation, page: 2, page_size: 2)
    records = page.records

    assert_equal 2, records.limit_value
    assert_equal 2, records.offset_value
  end

  test "first? should return true for first page" do
    page = PinFlags::Page.new(@relation, page: 1)
    assert page.first?

    page = PinFlags::Page.new(@relation, page: 2)
    assert_not page.first?
  end

  test "last? should return true for last page" do
    # With 5 records and page_size 3, we have 2 pages
    page = PinFlags::Page.new(@relation, page: 2, page_size: 3)
    assert page.last?

    page = PinFlags::Page.new(@relation, page: 1, page_size: 3)
    assert_not page.last?
  end

  test "last? should return true when empty" do
    empty_relation = PinFlags::FeatureTag.where(name: "nonexistent")
    page = PinFlags::Page.new(empty_relation, page: 1)
    assert page.last?
  end

  test "empty? should return true when no records" do
    empty_relation = PinFlags::FeatureTag.where(name: "nonexistent")
    page = PinFlags::Page.new(empty_relation)
    assert page.empty?

    page = PinFlags::Page.new(@relation)
    assert_not page.empty?
  end

  test "previous_index should return correct previous page" do
    page = PinFlags::Page.new(@relation, page: 3)
    assert_equal 2, page.previous_index

    # First page should stay at 1
    page = PinFlags::Page.new(@relation, page: 1)
    assert_equal 1, page.previous_index
  end

  test "next_index should return correct next page" do
    page = PinFlags::Page.new(@relation, page: 1, page_size: 3)
    assert_equal 2, page.next_index

    # Last page should not exceed pages_count
    page = PinFlags::Page.new(@relation, page: 2, page_size: 3)
    assert_equal 2, page.next_index
  end

  test "next_index should increment when pages_count is nil" do
    # Create a page object with a relation that will return infinity for count
    page = PinFlags::Page.new(@relation, page: 1)
    # Override the total_count method to return infinity
    page.define_singleton_method(:total_count) { Float::INFINITY }
    assert_equal 2, page.next_index
  end

  test "pages_count should calculate correct number of pages" do
    # 5 records with page_size 3 = 2 pages
    page = PinFlags::Page.new(@relation, page: 1, page_size: 3)
    assert_equal 2, page.pages_count

    # 5 records with page_size 5 = 1 page
    page = PinFlags::Page.new(@relation, page: 1, page_size: 5)
    assert_equal 1, page.pages_count

    # 5 records with page_size 10 = 1 page
    page = PinFlags::Page.new(@relation, page: 1, page_size: 10)
    assert_equal 1, page.pages_count
  end

  test "pages_count should return nil when total_count is infinite" do
    page = PinFlags::Page.new(@relation)
    # Override the total_count method to return infinity
    page.define_singleton_method(:total_count) { Float::INFINITY }
    assert_nil page.pages_count
  end

  test "total_count should return correct count" do
    page = PinFlags::Page.new(@relation)
    assert_equal 5, page.total_count
  end

  test "total_count should be memoized" do
    page = PinFlags::Page.new(@relation)

    # First call
    count1 = page.total_count

    # Add a record
    PinFlags::FeatureTag.create!(name: "new_feature", enabled: true)

    # Second call should return cached value
    count2 = page.total_count

    assert_equal count1, count2
    assert_equal 5, count2 # Should still be 5, not 6
  end

  test "offset should calculate correct offset" do
    page = PinFlags::Page.new(@relation, page: 1, page_size: 3)
    assert_equal 0, page.send(:offset)

    page = PinFlags::Page.new(@relation, page: 2, page_size: 3)
    assert_equal 3, page.send(:offset)

    page = PinFlags::Page.new(@relation, page: 3, page_size: 5)
    assert_equal 10, page.send(:offset)
  end

  test "should handle edge cases with zero records" do
    empty_relation = PinFlags::FeatureTag.where(name: "nonexistent")
    page = PinFlags::Page.new(empty_relation)

    assert_equal 0, page.total_count
    assert page.empty?
    assert page.first?
    assert page.last?
    assert_equal 0, page.pages_count  # 0 records = 0 pages
    assert_equal 1, page.previous_index
    assert_equal 2, page.next_index  # When pages_count is 0 (falsy), it returns index + 1
  end

  test "should handle large page numbers gracefully" do
    page = PinFlags::Page.new(@relation, page: 1000, page_size: 3)

    assert_equal 1000, page.index
    assert_not page.first?
    assert page.last? # Should be true since we're beyond the actual pages
  end

  def teardown
    PinFlags::FeatureTag.destroy_all
  end
end
