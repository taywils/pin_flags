module PinFlags
  class FeatureSubscription < ApplicationRecord
    self.table_name = "pin_flags_feature_subscriptions"

    belongs_to :feature_tag
    belongs_to :feature_taggable, polymorphic: true

    validates :feature_taggable_id, uniqueness: {
      scope: %i[feature_tag_id feature_taggable_type],
      message: "already has this feature tag applied"
    }

    def self.create_in_bulk(feature_tag:, feature_taggable_type:, feature_taggable_ids:)
      BulkProcessor.new(
        feature_tag: feature_tag,
        feature_taggable_type: feature_taggable_type,
        feature_taggable_ids: feature_taggable_ids
      ).process
    end
  end
end
