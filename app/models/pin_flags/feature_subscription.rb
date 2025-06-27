module PinFlags
  class FeatureSubscription < ApplicationRecord
    self.table_name = "pin_flags_feature_subscriptions"

    belongs_to :feature_tag
    belongs_to :feature_taggable, polymorphic: true

    validates :feature_taggable_id, uniqueness: {
      scope: %i[feature_tag_id feature_taggable_type],
      message: "already has this feature tag applied"
    }
  end
end
