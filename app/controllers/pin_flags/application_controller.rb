module PinFlags
  class ApplicationController < ActionController::Base
    include PinFlags::BasicAuthentication

    layout "pin_flags/application"
    protect_from_forgery with: :exception
  end
end
