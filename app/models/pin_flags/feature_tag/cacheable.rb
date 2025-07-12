module PinFlags::FeatureTag::Cacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_cache
  end

  class_methods do
    def clear_tag_cache(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      Rails.cache.delete("#{PinFlags.cache_prefix}:enabled:#{normalized_name}")
    end

    def clear_all_cache
      Rails.cache.delete_matched("#{PinFlags.cache_prefix}:*")
    end

    def enabled?(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      cache_key = "#{PinFlags.cache_prefix}:enabled:#{normalized_name}"

      Rails.cache.fetch(cache_key, expires_in: PinFlags.cache_expiry) do
        enabled.exists?(name: normalized_name)
      end
    end

    def disabled?(tag_name)
      !enabled?(tag_name)
    end

    private

    def cache_key_for(tag_name)
      normalized_name = normalize_tag_name(tag_name)
      "#{PinFlags.cache_prefix}:enabled:#{normalized_name}"
    end
  end

  private

  def clear_cache
    self.class.clear_tag_cache(name)
  end
end
