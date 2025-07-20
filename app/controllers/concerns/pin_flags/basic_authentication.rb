module PinFlags::BasicAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_by_http_basic
  end

  private
    def authenticate_by_http_basic
      if http_basic_authentication_enabled?
        http_basic_authenticate_or_request_with(**http_basic_authentication_credentials)
      end
    end

    def http_basic_authentication_enabled?
      PinFlags.http_basic_auth_enabled
    end

    def http_basic_authentication_credentials
      {
        name: PinFlags.http_basic_auth_user,
        password: PinFlags.http_basic_auth_password
      }.transform_values(&:presence)
    end
end
