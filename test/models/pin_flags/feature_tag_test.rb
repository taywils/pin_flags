require "test_helper"

module PinFlags
  class FeatureTagTest < ActiveSupport::TestCase
    # Normalizations
    test "normalizes name from various formats" do
      tag_names = [ "Foo Bar", "  Foo Bar  ", "Foo Bar", "Foo  Bar" ]
      tag_names.each do |tag_name|
        feature_tag = FeatureTag.new(name: tag_name, enabled: true)
        assert_equal "foo_bar", feature_tag.name
      end
    end

    test "ensures name uniqueness after normalization" do
      feature_tag = FeatureTag.new(name: "  Live Feature  ", enabled: true)
      refute feature_tag.valid?
    end

    # Validations
    test "validates presence of name" do
      tag = FeatureTag.new(name: "", enabled: true)
      refute tag.valid?
    end

    test "validates uniqueness of name" do
      tag = FeatureTag.new(name: pin_flags_feature_tags(:live_feature).name, enabled: true)
      refute tag.valid?
    end

    # Scopes
    test "enabled scope returns only enabled feature tags" do
      assert_equal [ pin_flags_feature_tags(:popular_feature), pin_flags_feature_tags(:live_feature) ].sort, FeatureTag.enabled.to_a.sort
    end

    test "disabled scope returns only disabled feature tags" do
      assert_equal [ pin_flags_feature_tags(:old_feature), pin_flags_feature_tags(:beta_feature) ].sort, FeatureTag.disabled.to_a.sort
    end

    test "with_name_like matches partial, case-insensitive, and normalized names" do
      live_feature    = pin_flags_feature_tags(:live_feature)
      popular_feature = pin_flags_feature_tags(:popular_feature)
      beta_feature    = pin_flags_feature_tags(:beta_feature)
      old_feature     = pin_flags_feature_tags(:old_feature)

      # Should match on partials for "live_feature"
      assert_includes FeatureTag.with_name_like("live"), live_feature
      assert_includes FeatureTag.with_name_like("LIVE"), live_feature
      assert_includes FeatureTag.with_name_like("feature"), live_feature
      assert_includes FeatureTag.with_name_like("  Live  "), live_feature
      assert_includes FeatureTag.with_name_like("live_feature"), live_feature
      assert_includes FeatureTag.with_name_like("LIV"), live_feature

      # Should match on partials for "popular_feature"
      assert_includes FeatureTag.with_name_like("popular"), popular_feature
      assert_includes FeatureTag.with_name_like("POPULAR"), popular_feature
      assert_includes FeatureTag.with_name_like("pop"), popular_feature

      # Should match on partials for "beta_feature"
      assert_includes FeatureTag.with_name_like("beta"), beta_feature
      assert_includes FeatureTag.with_name_like("BETA"), beta_feature

      # Should match on partials for "old_feature"
      assert_includes FeatureTag.with_name_like("old"), old_feature
      assert_includes FeatureTag.with_name_like("OLD"), old_feature

      # Should not match unrelated search terms
      refute_includes FeatureTag.with_name_like("notfound"), live_feature
      refute_includes FeatureTag.with_name_like("xyz"), popular_feature
      refute_includes FeatureTag.with_name_like("random"), beta_feature

      # Cross-fixture negative tests
      refute_includes FeatureTag.with_name_like("beta"), live_feature
      refute_includes FeatureTag.with_name_like("popular"), beta_feature
      refute_includes FeatureTag.with_name_like("old"), live_feature
    end

    # .enabled?
    test "enabled? returns true for enabled tag" do
      assert FeatureTag.enabled?("live_feature")
    end

    test "enabled? returns false for disabled tag" do
      refute FeatureTag.enabled?("beta_feature")
    end

    # .disabled?
    test "disabled? returns true for disabled tag" do
      assert FeatureTag.disabled?("beta_feature")
    end

    test "disabled? returns false for enabled tag" do
      refute FeatureTag.disabled?("live_feature")
    end

    # .enable
    test "enable method enables a feature tag" do
      feature_tag = pin_flags_feature_tags(:beta_feature)
      FeatureTag.enable(feature_tag.name)
      assert feature_tag.reload.enabled
    end

    # .disable
    test "disable method disables a feature tag" do
      feature_tag = pin_flags_feature_tags(:live_feature)
      FeatureTag.disable(feature_tag.name)
      refute feature_tag.reload.enabled
    end

    # .feature_taggable_models
    test "feature_taggable_models returns models that include FeatureTaggable" do
      models = FeatureTag.feature_taggable_models
      assert models.is_a?(Array)
    end

    # .feature_taggable_options_for_select
    test "feature_taggable_options_for_select returns array of name/value pairs" do
      options = FeatureTag.feature_taggable_options_for_select
      assert options.is_a?(Array)
    end

    # Export JSON
    test "export_as_json generates valid JSON" do
      json = FeatureTag.export_as_json
      parsed = JSON.parse(json)
      assert parsed.is_a?(Array)
    end

    # Import from fixtures/files
    test "import_from_json creates or updates feature tags" do
      json_data = load_fixture_file("feature_tag_valid_import_example.json")

      # Parse to see what we're importing
      parsed_data = JSON.parse(json_data)

      FeatureTag.import_from_json(json_data)

      # Should have created records for each entry in the JSON
      parsed_data.each do |tag_data|
        tag = FeatureTag.find_by(name: tag_data["name"])
        assert_not_nil tag, "Tag '#{tag_data["name"]}' should exist after import"
        assert_equal tag_data["enabled"], tag.enabled, "Tag '#{tag_data["name"]}' should have correct enabled state"
      end
    end

    test "import_from_json handles invalid JSON" do
      assert_raises(FeatureTagImportError) do
        FeatureTag.import_from_json("invalid json")
      end
    end

    test "import_from_json imports correct data" do
      json_data = load_fixture_file("feature_tag_valid_import_example.json")

      FeatureTag.import_from_json(json_data)

      # Test a few specific imports
      assert FeatureTag.find_by(name: "ai_questionnaire_descriptions").enabled
      refute FeatureTag.find_by(name: "beta_version").enabled
      assert FeatureTag.find_by(name: "silly_feature").enabled
    end

    test "import_from_json avoids duplicates on re-import" do
      json_data = load_fixture_file("feature_tag_valid_import_example.json")

      # Import once
      FeatureTag.import_from_json(json_data)
      count_after_first_import = FeatureTag.count

      # Import again - should not create duplicates
      FeatureTag.import_from_json(json_data)
      count_after_second_import = FeatureTag.count

      assert_equal count_after_first_import, count_after_second_import
    end

    private

    # Helper method to load fixture files from the engine's test directory
    def load_fixture_file(filename)
      # Get the engine root directory by going up from the test file location
      engine_root = File.expand_path("../../../", __dir__)
      fixture_path = File.join(engine_root, "test", "fixtures", "files", filename)
      File.read(fixture_path)
    end
  end
end
