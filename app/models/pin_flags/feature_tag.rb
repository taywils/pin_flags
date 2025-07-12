module PinFlags
  class FeatureTagImportError < StandardError; end

  class FeatureTag < ApplicationRecord
    include PinFlags::FeatureTag::Cacheable

    self.table_name = "pin_flags_feature_tags"

    has_many :feature_subscriptions, dependent: :destroy
    has_many :feature_taggables, through: :feature_subscriptions

    MIN_NAME_LENGTH ||= 3
    MAX_NAME_LENGTH ||= 64

    validates :name, presence: true, uniqueness: true, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }
    validates :enabled, inclusion: { in: [ true, false ] }

    normalizes :name, with: ->(value) { value.strip.downcase.parameterize.underscore }

    scope :enabled, -> { where(enabled: true) }
    scope :disabled, -> { where(enabled: false) }
    scope :with_name_like, ->(name) {
      where("LOWER(name) LIKE LOWER(?)", "%#{normalize_tag_name(name)}%")
    }

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

      # Find all classes that include FeatureTaggable
      ObjectSpace.each_object(Class).select do |klass|
        klass < ActiveRecord::Base &&
        klass.included_modules.include?(PinFlags::FeatureTaggable)
      end.uniq
    end

    def self.feature_taggable_options_for_select
      feature_taggable_models.map { [ it.name, it.name ] }.sort
    end

    def self.export_as_json
      all.as_json(only: [ :name, :enabled ]).to_json
    end

    def self.import_from_json(json, batch_size: 1000)
      data = JSON.parse(json)

      data.each_slice(batch_size) do |batch|
        normalized_batch = batch.map do |item|
          {
            name: normalize_tag_name(item["name"]),
            enabled: item["enabled"],
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        # Use upsert_all for efficient bulk operations
        upsert_all(
          normalized_batch,
          unique_by: :name,
          update_only: [ :enabled, :updated_at ]
        )
      end

      clear_all_cache
      true
    rescue JSON::ParserError
      raise PinFlags::FeatureTagImportError, "Invalid JSON format"
    rescue StandardError => e
      raise PinFlags::FeatureTagImportError, "Import failed: #{e.message}"
    end

    def self.normalize_tag_name(tag_name)
      tag_name.to_s.strip.downcase.parameterize.underscore
    end
  end
end
