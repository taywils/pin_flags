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
      feature_taggable_ids = feature_taggable_ids.map(&:strip)

      # Validate that the feature_taggable_type is a valid class
      begin
        feature_taggable_type.constantize
      rescue NameError
        return false
      end

      ActiveRecord::Base.transaction do
        feature_taggable_ids.each do |feature_taggable_id|
          feature_tag.feature_subscriptions.find_or_create_by!(
            feature_taggable_type: feature_taggable_type,
            feature_taggable_id: feature_taggable_id
          )
        rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => _e
          raise ActiveRecord::Rollback
        end
        return true
      end
      false
    end
  end
end
