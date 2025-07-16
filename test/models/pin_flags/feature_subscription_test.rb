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
      subscription = PinFlags::FeatureSubscription.new(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )
      assert subscription.valid?
    end

    test "is invalid when feature_taggable polymorphic association is not set" do
      subscription = PinFlags::FeatureSubscription.new(
        feature_tag: @feature_tag
      )
      refute subscription.valid?
    end

    test "is invalid when feature_tag is not set" do
      subscription = PinFlags::FeatureSubscription.new(
        feature_taggable: @user
      )
      refute subscription.valid?
    end

    test "is invalid when both associations are not set" do
      subscription = PinFlags::FeatureSubscription.new
      refute subscription.valid?
    end

    test "validates uniqueness of feature_taggable_id scoped to feature_tag_id and feature_taggable_type" do
      # Create first subscription
      PinFlags::FeatureSubscription.create!(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      # Try to create duplicate
      duplicate_subscription = PinFlags::FeatureSubscription.new(
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
      subscription = PinFlags::FeatureSubscription.find_by(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      assert_not_nil subscription
      assert_equal @feature_tag, subscription.feature_tag
      assert_equal @user, subscription.feature_taggable
    end

    test "polymorphic association sets correct type and id" do
      subscription = PinFlags::FeatureSubscription.create!(
        feature_tag: @feature_tag,
        feature_taggable: @user
      )

      assert_equal "PinFlags::FeatureSubscriptionTest::TestUser", subscription.feature_taggable_type
      assert_equal @user.id, subscription.feature_taggable_id
      assert_equal @user, subscription.feature_taggable
    end

    # Test table name
    test "uses correct table name" do
      assert_equal "pin_flags_feature_subscriptions", PinFlags::FeatureSubscription.table_name
    end

    test "feature_tag_unpin removes feature tag" do
      @user.feature_tag_pin(@feature_tag.name)
      assert @user.feature_tag?(@feature_tag.name)

      @user.feature_tag_unpin(@feature_tag.name)
      refute @user.feature_tag?(@feature_tag.name)
    end

    test "feature_tag? returns true when user has feature tag" do
      @user.feature_tag_pin(@feature_tag.name)
      assert @user.feature_tag?(@feature_tag.name)
    end

    test "feature_tag? returns false when user does not have feature tag" do
      refute @user.feature_tag?(@feature_tag.name)
    end

    test "feature_tag_enabled? returns true for enabled pinned tags" do
      @user.feature_tag_pin(@feature_tag.name)  # @feature_tag is enabled
      assert @user.feature_tag_enabled?(@feature_tag.name)
    end

    test "feature_tag_disabled? returns true for disabled pinned tags" do
      disabled_tag = FeatureTag.create!(name: "disabled_feature", enabled: false)
      @user.feature_tag_pin(disabled_tag.name)
      assert @user.feature_tag_disabled?(disabled_tag.name)
    end

    test "feature_tag_pin raises RecordInvalid on duplicate pins" do
      @user.feature_tag_pin(@feature_tag.name)

      assert_raises(ActiveRecord::RecordInvalid) do
        @user.feature_tag_pin(@feature_tag.name)  # Should raise error on duplicate
      end

      # Should still only have one subscription after the failed attempt
      assert_equal 1, @user.feature_subscriptions.count
    end

    # Test create_in_bulk method
    test "create_in_bulk creates multiple subscriptions successfully" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")
      user2 = TestUser.create!(name: "User 2", email: "user2@example.com")
      user3 = TestUser.create!(name: "User 3", email: "user3@example.com")

      user_ids = [ user1.id.to_s, user2.id.to_s, user3.id.to_s ]

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: "PinFlags::FeatureSubscriptionTest::TestUser",
        feature_taggable_ids: user_ids
      )

      assert result
      assert_equal 3, @feature_tag.feature_subscriptions.count
      assert_equal 3, PinFlags::FeatureSubscription.where(feature_tag: @feature_tag).count

      # Verify each subscription was created correctly
      [ user1, user2, user3 ].each do |user|
        subscription = PinFlags::FeatureSubscription.find_by(
          feature_tag: @feature_tag,
          feature_taggable: user
        )
        assert_not_nil subscription
        assert_equal @feature_tag, subscription.feature_tag
        assert_equal user, subscription.feature_taggable
      end
    end

    test "create_in_bulk handles whitespace in IDs" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")
      user2 = TestUser.create!(name: "User 2", email: "user2@example.com")

      # Include whitespace in the IDs
      user_ids = [ " #{user1.id} ", "\t#{user2.id}\n" ]

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: "PinFlags::FeatureSubscriptionTest::TestUser",
        feature_taggable_ids: user_ids
      )

      assert result
      assert_equal 2, @feature_tag.feature_subscriptions.count

      # Verify subscriptions were created with correct IDs (whitespace stripped)
      [ user1, user2 ].each do |user|
        subscription = PinFlags::FeatureSubscription.find_by(
          feature_tag: @feature_tag,
          feature_taggable: user
        )
        assert_not_nil subscription
      end
    end

    test "create_in_bulk creates existing subscriptions without error (find_or_create_by)" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")
      user2 = TestUser.create!(name: "User 2", email: "user2@example.com")

      # Create one subscription manually first
      existing_subscription = PinFlags::FeatureSubscription.create!(
        feature_tag: @feature_tag,
        feature_taggable: user1
      )

      user_ids = [ user1.id.to_s, user2.id.to_s ]

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: "PinFlags::FeatureSubscriptionTest::TestUser",
        feature_taggable_ids: user_ids
      )

      assert result
      assert_equal 2, @feature_tag.feature_subscriptions.count

      # Verify the existing subscription is still there
      assert_equal existing_subscription, PinFlags::FeatureSubscription.find_by(
        feature_tag: @feature_tag,
        feature_taggable: user1
      )

      # Verify the new subscription was created
      assert_not_nil PinFlags::FeatureSubscription.find_by(
        feature_tag: @feature_tag,
        feature_taggable: user2
      )
    end

    test "create_in_bulk returns false and rolls back transaction on error" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")

      # Use an invalid feature_taggable_type to trigger an error
      invalid_type = "NonExistentClass"
      user_ids = [ user1.id.to_s ]

      initial_count = PinFlags::FeatureSubscription.count

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: invalid_type,
        feature_taggable_ids: user_ids
      )

      refute result
      # Verify no subscriptions were created due to rollback
      assert_equal initial_count, PinFlags::FeatureSubscription.count
    end

    test "create_in_bulk returns false for invalid feature_taggable_type" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")

      # Use an invalid feature_taggable_type
      invalid_type = "NonExistentClass"
      user_ids = [ user1.id.to_s ]

      initial_count = PinFlags::FeatureSubscription.count

      # Should return false without raising an error
      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: invalid_type,
        feature_taggable_ids: user_ids
      )

      refute result
      # Verify no subscriptions were created
      assert_equal initial_count, PinFlags::FeatureSubscription.count
    end

    test "create_in_bulk returns false for invalid namespaced feature_taggable_type" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")

      # Use an invalid namespaced feature_taggable_type
      invalid_type = "SomeModule::NonExistentClass"
      user_ids = [ user1.id.to_s ]

      initial_count = PinFlags::FeatureSubscription.count

      # Should return false without raising an error
      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: invalid_type,
        feature_taggable_ids: user_ids
      )

      refute result
      # Verify no subscriptions were created
      assert_equal initial_count, PinFlags::FeatureSubscription.count
    end

    test "create_in_bulk returns false for non-existent feature_taggable_ids" do
      user1 = TestUser.create!(name: "User 1", email: "user1@example.com")

      # Mix valid and invalid IDs
      valid_id = user1.id.to_s
      invalid_id = "99999" # ID that doesn't exist
      user_ids = [ valid_id, invalid_id ]

      initial_count = PinFlags::FeatureSubscription.count

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: "PinFlags::FeatureSubscriptionTest::TestUser",
        feature_taggable_ids: user_ids
      )

      refute result
      # Verify no subscriptions were created when invalid IDs are present
      assert_equal initial_count, PinFlags::FeatureSubscription.count
    end

    test "create_in_bulk returns false for all non-existent feature_taggable_ids" do
      # Use only invalid IDs
      invalid_ids = [ "99999", "88888" ]

      initial_count = PinFlags::FeatureSubscription.count

      result = PinFlags::FeatureSubscription.create_in_bulk(
        feature_tag: @feature_tag,
        feature_taggable_type: "PinFlags::FeatureSubscriptionTest::TestUser",
        feature_taggable_ids: invalid_ids
      )

      refute result
      # Verify no subscriptions were created
      assert_equal initial_count, PinFlags::FeatureSubscription.count
    end

    # Tests for FeatureTag.enabled_for_subscriber?
    test "enabled_for_subscriber? returns true when tag is enabled globally and user has it pinned" do
      PinFlags::FeatureTag.enable(@feature_tag.name)
      @user.feature_tag_pin(@feature_tag.name)

      assert PinFlags::FeatureTag.enabled_for_subscriber?(@feature_tag.name, @user)
    end

    test "enabled_for_subscriber? returns false when tag is disabled globally even if user has it pinned" do
      PinFlags::FeatureTag.disable(@feature_tag.name)
      @user.feature_tag_pin(@feature_tag.name)

      refute PinFlags::FeatureTag.enabled_for_subscriber?(@feature_tag.name, @user)
    end

    test "enabled_for_subscriber? returns false when tag is enabled globally but user doesn't have it pinned" do
      PinFlags::FeatureTag.enable(@feature_tag.name)
      # Don't pin the tag to the user

      refute PinFlags::FeatureTag.enabled_for_subscriber?(@feature_tag.name, @user)
    end

    test "enabled_for_subscriber? handles normalized tag names" do
      PinFlags::FeatureTag.enable(@feature_tag.name)
      @user.feature_tag_pin("Live Feature")  # Non-normalized input

      assert PinFlags::FeatureTag.enabled_for_subscriber?("Live Feature", @user)
      assert PinFlags::FeatureTag.enabled_for_subscriber?("live_feature", @user)
      assert PinFlags::FeatureTag.enabled_for_subscriber?("LIVE_FEATURE", @user)
    end

    test "enabled_for_subscriber? returns false for nonexistent tag" do
      refute PinFlags::FeatureTag.enabled_for_subscriber?("nonexistent_feature", @user)
    end

    test "enabled_for_subscriber? returns false when tag exists but user doesn't exist" do
      PinFlags::FeatureTag.enable(@feature_tag.name)
      deleted_user = TestUser.create!(name: "Temp User", email: "temp@example.com")
      deleted_user.feature_tag_pin(@feature_tag.name)
      deleted_user.destroy

      refute PinFlags::FeatureTag.enabled_for_subscriber?(@feature_tag.name, deleted_user)
    end
  end
end
