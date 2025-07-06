module PinFlags
  module FeatureTaggable
    extend ActiveSupport::Concern

    included do
      has_many  :feature_subscriptions,
                class_name: "PinFlags::FeatureSubscription",
                as: :feature_taggable,
                dependent: :destroy

      has_many  :feature_tags,
                class_name: "PinFlags::FeatureTag",
                through: :feature_subscriptions
    end

    def feature_tag_pin(tag_name)
      feature_tags << PinFlags::FeatureTag.find_or_create_by(name: tag_name)
    rescue ActiveRecord::RecordNotUnique
      feature_tags
    end

    def feature_tag_unpin(tag_name)
      existing_tag = feature_tags.find_by(name: tag_name)
      feature_tags.delete(existing_tag) if existing_tag
    end

    def feature_tag?(tag_name)
      feature_tags.exists?(name: tag_name)
    end

    def feature_tag_enabled?(tag_name)
      feature_tags.enabled.exists?(name: tag_name)
    end

    def feature_tag_disabled?(tag_name)
      feature_tags.disabled.exists?(name: tag_name)
    end
  end
end
