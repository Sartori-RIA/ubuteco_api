# frozen_string_literal: true

# lib/jwt_authentication.rb
require 'jwt'

class JwtAuthentication
  def initialize(app)
    @app = app
  end

  def call(env)
    auth_header = env['HTTP_AUTHORIZATION']
    return [401, { 'Content-Type' => 'text/plain' }, ['Unauthorized']] unless auth_header

    token = auth_header.split.last
    begin
      decoded_token = JWT.decode(token, ENV.fetch('JWT_SECRET', nil), true, { algorithm: 'HS256' })
      env[:decoded_token] = decoded_token
      @app.call(env)
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'text/plain' }, ['Unauthorized']]
    end
  end
end
