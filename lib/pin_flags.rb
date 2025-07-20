require "pin_flags/version"
require "pin_flags/engine"
require "active_support/core_ext/numeric/time"

module PinFlags
  mattr_accessor :cache_prefix, default: "pin_flags"
  mattr_accessor :cache_expiry, default: 12.hours

  mattr_accessor :http_basic_auth_enabled, default: true
  mattr_accessor :http_basic_auth_user, default: "pin_flags_admin"
  mattr_accessor :http_basic_auth_password, default: "please_change_me"

  def self.config
    yield self if block_given?
    self
  end
end
