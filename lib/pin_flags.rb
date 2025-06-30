require "pin_flags/version"
require "pin_flags/engine"
require "active_support/core_ext/numeric/time"

module PinFlags
  mattr_accessor :cache_prefix, default: "pin_flags"
  mattr_accessor :cache_expiry, default: 12.hours

  def self.config
    yield self if block_given?
    self
  end
end
