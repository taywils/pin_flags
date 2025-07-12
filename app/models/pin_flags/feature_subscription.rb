module PinFlags
  class FeatureSubscription < ApplicationRecord
    self.table_name = "pin_flags_feature_subscriptions"

    belongs_to :feature_tag
    belongs_to :feature_taggable, polymorphic: true

    validates :feature_taggable_id, uniqueness: {
      scope: %i[feature_tag_id feature_taggable_type],
      message: "already has this feature tag applied"
    }

    # TODO: Move this code into a PORO, PinFlags::FeatureSubscription::BulkProcessor
    def self.create_in_bulk(feature_tag:, feature_taggable_type:, feature_taggable_ids:)
      feature_taggable_ids = feature_taggable_ids.map(&:strip)

      # Validate that the feature_taggable_type is a valid class
      begin
        klass = feature_taggable_type.constantize
      rescue NameError
        return false
      end

      # Validate that all feature_taggable_ids exist in the database
      existing_ids = klass.where(id: feature_taggable_ids).pluck(:id).map(&:to_s)
      invalid_ids = feature_taggable_ids - existing_ids

      return false if invalid_ids.any?

      # Prepare records for upsert_all
      records = feature_taggable_ids.map do |feature_taggable_id|
        {
          feature_tag_id: feature_tag.id,
          feature_taggable_type: feature_taggable_type,
          feature_taggable_id: feature_taggable_id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      begin
        # Use upsert_all to insert or update records in bulk
        PinFlags::FeatureSubscription.upsert_all(
          records,
          unique_by: [ :feature_tag_id, :feature_taggable_type, :feature_taggable_id ]
        )
        true
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => _e
        false
      end
    end
  end
end
