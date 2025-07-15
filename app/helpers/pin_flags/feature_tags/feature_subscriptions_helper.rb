module PinFlags
  module FeatureTags
    module FeatureSubscriptionsHelper
      def display_feature_subscription_table_turbo_frame_row_id(feature_subscription)
        "feature_subscriptions_table_row_#{dom_id(feature_subscription)}"
      end

      def display_feature_subscription_row_delete_confirmation(feature_subscription)
        taggable_type = strip_tags(feature_subscription.feature_taggable_type)
        taggable_id = feature_subscription.feature_taggable_id

        "Are you sure you want to delete the feature subscription for '#{taggable_type}' with ID '#{taggable_id}'?"
      end

      def display_feature_subscription_delete_button_aria_label(feature_subscription)
        feature_taggable_type = strip_tags(feature_subscription.feature_taggable_type)
        feature_taggable_id = feature_subscription.feature_taggable_id

        "Delete Feature Subscription for #{feature_taggable_type} with ID #{feature_taggable_id}"
      end
    end
  end
end
