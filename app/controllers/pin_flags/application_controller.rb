module PinFlags
  class ApplicationController < ActionController::Base
    include PinFlags::BasicAuthentication

    layout "pin_flags/application"
    protect_from_forgery with: :exception

    before_action :verify_turbo_rails!

    private

    def verify_turbo_rails!
      return if defined?(Turbo)

      render plain: "PinFlags requires turbo-rails. Add `gem 'turbo-rails'` to your Gemfile.", status: :service_unavailable
    end
  end
end
