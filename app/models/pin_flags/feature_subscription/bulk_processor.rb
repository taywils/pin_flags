class PinFlags::FeatureSubscription::BulkProcessor
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :feature_tag
  attribute :feature_taggable_type, :string

  attr_accessor :feature_taggable_ids

  validates :feature_tag, presence: true
  validates :feature_taggable_type, presence: true
  validates :feature_taggable_ids, presence: true
  validate :validate_feature_taggable_type_is_valid_class
  validate :validate_feature_taggable_ids_exist

  def initialize(attributes = {})
    super
    @feature_taggable_ids = Array(attributes[:feature_taggable_ids]) if attributes[:feature_taggable_ids]
  end

  def process
    return false unless valid?

    # Prepare records for upsert_all
    records = sanitized_feature_taggable_ids.map do |feature_taggable_id|
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

  private

  def sanitized_feature_taggable_ids
    @sanitized_feature_taggable_ids ||= Array(feature_taggable_ids).map(&:strip)
  end

  def feature_taggable_class
    @feature_taggable_class ||= feature_taggable_type.constantize
  rescue NameError
    nil
  end

  def validate_feature_taggable_type_is_valid_class
    return if feature_taggable_type.blank?

    if feature_taggable_class.nil?
      errors.add(:feature_taggable_type, "is not a valid class")
    end
  end

  def validate_feature_taggable_ids_exist
    return if feature_taggable_ids.blank? || feature_taggable_class.nil?

    existing_ids = feature_taggable_class.where(id: sanitized_feature_taggable_ids)
                                        .pluck(:id)
                                        .map(&:to_s)
    invalid_ids = sanitized_feature_taggable_ids - existing_ids

    if invalid_ids.any?
      errors.add(:feature_taggable_ids, "contain non-existent IDs: #{invalid_ids.join(', ')}")
    end
  end
end
