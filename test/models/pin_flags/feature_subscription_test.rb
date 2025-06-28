require "test_helper"

module PinFlags
  class FeatureSubscriptionTest < ActiveSupport::TestCase
    TEST_TABLE_NAME = "test_users"

    # Create a test model with actual database table
    class TestUser < ActiveRecord::Base
      self.table_name = TEST_TABLE_NAME

      include FeatureTaggable

      validates :name, presence: true
      validates :email, presence: true
    end

    def self.setup_test_table
      # Create table if it doesn't exist
      unless ActiveRecord::Base.connection.table_exists?(TEST_TABLE_NAME)
        ActiveRecord::Base.connection.create_table TEST_TABLE_NAME do |t|
          t.string :name
          t.string :email
          t.timestamps
        end
      end
    end

    def self.teardown_test_table
      ActiveRecord::Base.connection.drop_table TEST_TABLE_NAME if ActiveRecord::Base.connection.table_exists?(TEST_TABLE_NAME)
    end

    setup do
      self.class.setup_test_table
      @feature_tag = pin_flags_feature_tags(:live_feature)
      @user = TestUser.create!(name: "Test User", email: "test@example.com")
    end

    teardown do
      TestUser.delete_all if ActiveRecord::Base.connection.table_exists?(TEST_TABLE_NAME)
    end

    # Association tests
    test "has valid attributes when feature_taggable is set" do
      subscription = FeatureSubscription.new(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )
      assert subscription.valid?
    end

    test "is invalid when feature_taggable polymorphic association is not set" do
      subscription = FeatureSubscription.new(
        feature_tag: @feature_tag
      )
      refute subscription.valid?
    end

    test "is invalid when feature_tag is not set" do
      subscription = FeatureSubscription.new(
        feature_taggable: @user
      )
      refute subscription.valid?
    end

    test "is invalid when both associations are not set" do
      subscription = FeatureSubscription.new
      refute subscription.valid?
    end

    test "validates uniqueness of feature_taggable_id scoped to feature_tag_id and feature_taggable_type" do
      # Create first subscription
      FeatureSubscription.create!(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      # Try to create duplicate
      duplicate_subscription = FeatureSubscription.new(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      refute duplicate_subscription.valid?
      assert_includes duplicate_subscription.errors[:feature_taggable_id],
                      "already has this feature tag applied"
    end

    # Test the FeatureTaggable concern methods through associations
    test "feature_taggable association works with FeatureTaggable concern" do
      # Use the concern's methods to create subscription
      @user.feature_tag_pin(@feature_tag.name)

      # Verify the subscription was created
      subscription = FeatureSubscription.find_by(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      assert_not_nil subscription
      assert_equal @feature_tag, subscription.feature_tag
      assert_equal @user, subscription.feature_taggable
    end

    test "polymorphic association sets correct type and id" do
      subscription = FeatureSubscription.create!(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      assert_equal "PinFlags::FeatureSubscriptionTest::TestUser", subscription.feature_taggable_type
      assert_equal @user.id, subscription.feature_taggable_id
      assert_equal @user, subscription.feature_taggable
    end

    # Test table name
    test "uses correct table name" do
      assert_equal "pin_flags_feature_subscriptions", FeatureSubscription.table_name
    end
  end
end
