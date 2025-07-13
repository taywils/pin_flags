module PinFlags
  module FeatureTagsHelper
    def display_feature_tag_table_turbo_frame_row_id(feature_tag)
      "feature_tags_table_row_#{dom_id(feature_tag)}"
    end

    def display_feature_tag_row_delete_confirmation(feature_tag)
      "Are you sure you want to delete the feature tag '#{feature_tag.name}'?"
    end
  end
end
