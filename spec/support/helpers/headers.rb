# frozen_string_literal: true

module Helpers
  module Headers
    def multipart_header(user)
      headers = { :Accept => 'application/json', 'Content-Type' => 'multipart/form-data' }
      Devise::JWT::TestHelpers.auth_headers(headers, user)
    end

    def auth_header(user)
      headers = { :Accept => 'application/json', 'Content-Type' => 'application/json' }
      Devise::JWT::TestHelpers.auth_headers(headers, user)
    end

    def unauthenticated_header
      { :Accept => 'application/json', 'Content-Type' => 'application/json' }
    end
  end
end
