require "test_helper"

module PinFlags
  class FeatureTagTest < ActiveSupport::TestCase
    set_fixture_class pin_flags_feature_tags: PinFlags::FeatureTag

    test "validates presence of name" do
      tag = FeatureTag.new(name: "", enabled: true)
      assert_not tag.valid?
    end

    test "validates uniqueness of name" do
      tag = FeatureTag.new(name: pin_flags_feature_tags(:live_feature).name, enabled: true)
      assert_not tag.valid?
    end

    test "enabled? returns true for enabled tag" do
      assert FeatureTag.enabled?("live_feature")
    end

    test "enabled? returns false for disabled tag" do
      assert_not FeatureTag.enabled?("beta_feature")
    end

    test "enable method enables a feature tag" do
      FeatureTag.enable("beta_feature")
      assert FeatureTag.enabled?("beta_feature")
    end

    test "disable method disables a feature tag" do
      FeatureTag.disable("live_feature")
      assert_not FeatureTag.enabled?("live_feature")
    end
  end
end
