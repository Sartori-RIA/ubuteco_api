module Helpers
  module Headers
    def auth_header(user)
      headers = {:Accept => 'application/json', 'Content-Type' => 'application/json' }
      Devise::JWT::TestHelpers.auth_headers(headers, user)
    end
  end
end
