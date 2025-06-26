# frozen_string_literal: true

# == Schema Information
#
# Table name: feature_subscriptions
#
#  id                    :integer          not null, primary key
#  feature_taggable_type :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  feature_tag_id        :integer          not null
#  feature_taggable_id   :integer          not null
#
# Indexes
#
#  index_feature_subscriptions_on_feature_tag_id            (feature_tag_id)
#  index_feature_subscriptions_on_feature_taggable          (feature_taggable_type,feature_taggable_id)
#  index_feature_subscriptions_on_tag_and_feature_taggable  (feature_tag_id,feature_taggable_type,feature_taggable_id) UNIQUE
#
# Foreign Keys
#
#  feature_tag_id  (feature_tag_id => feature_tags.id)
#

module PinFlags
  class FeatureSubscription < ApplicationRecord
    belongs_to :feature_tag
    belongs_to :feature_taggable, polymorphic: true

    validates :feature_taggable_id, uniqueness: {
      scope: %i[feature_tag_id feature_taggable_type],
      message: "already has this feature tag applied"
    }
  end
end
