# frozen_string_literal: true

# == Schema Information
#
# Table name: feature_tags
#
#  id         :integer          not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_feature_tags_on_name  (name) UNIQUE
#

module PinFlags
  class FeatureTagImportError < StandardError; end

  class FeatureTag < ApplicationRecord
    has_many :feature_subscriptions, dependent: :destroy
    has_many :feature_taggables, through: :feature_subscriptions

    MIN_NAME_LENGTH ||= 3
    MAX_NAME_LENGTH ||= 64

    validates :name, presence: true, uniqueness: true, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }
    validates :enabled, inclusion: { in: [ true, false ] }

    normalizes :name, with: ->(value) { value.strip.downcase.parameterize.underscore }

    scope :enabled, -> { where(enabled: true) }
    scope :disabled, -> { where(enabled: false) }

    after_commit :clear_cache

    def self.enabled?(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      cache_key = "#{PinFlags.cache_prefix}:enabled:#{normalized_name}"

      Rails.cache.fetch(cache_key, expires_in: PinFlags.cache_expiry) do
        enabled.exists?(name: normalized_name)
      end
    end

    def self.disabled?(tag_name)
      !enabled?(tag_name)
    end

    def self.enable(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      result = find_or_create_by(name: normalized_name).update!(enabled: true)
      clear_tag_cache(normalized_name)
      result
    end

    def self.disable(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      result = find_or_create_by(name: normalized_name).update!(enabled: false)
      clear_tag_cache(normalized_name)
      result
    end

    def self.enabled_for_subscriber?(tag_name, feature_taggable)
      normalized_name = normalize_tag_name(tag_name)
      return false unless enabled?(normalized_name)

      feature_taggable.feature_tag_enabled?(normalized_name)
    end

    def self.feature_taggable_models
      Rails.application.eager_load! unless Rails.application.config.eager_load

      ApplicationRecord.descendants.select do |model|
        model.included_modules.include?(FeatureTaggable)
      end
    end

    def self.feature_taggable_options_for_select
      feature_taggable_models.map { [ it.name, it.name ] }.sort
    end

    def self.export_as_json
      feature_tags = all
      Jbuilder.new do |json|
        json.array! feature_tags do |feature_tag|
          json.extract! feature_tag, :name, :enabled
        end
      end.target!
    end

    def self.import_from_json(json)
      JSON.parse(json).each do |feature_tag_data|
        feature_tag = find_or_initialize_by(name: feature_tag_data["name"])
        feature_tag.update!(enabled: feature_tag_data["enabled"])
      end
      clear_all_cache
      true
    rescue JSON::ParserError
      raise FeatureTagImportError, "Invalid JSON format"
    rescue StandardError => e
      raise FeatureTagImportError, "Import failed: #{e.message}"
    end

    def self.normalize_tag_name(tag_name)
      tag_name.to_s.strip.downcase.parameterize.underscore
    end

    def self.clear_tag_cache(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      Rails.cache.delete("#{PinFlags.cache_prefix}:enabled:#{normalized_name}")
    end

    def self.clear_all_cache
      Rails.cache.delete_matched("#{PinFlags.cache_prefix}:*")
    end

    private

    def clear_cache
      self.class.clear_tag_cache(name)
    end
  end
end
