# frozen_string_literal: true

require 'rails_helper'
require 'digest'
require 'webmock'

RSpec.describe 'Password policy', type: :request do
  let(:user) { create(:user, :admin, email: 'longlocalpart@email.com') }

  describe 'POST /auth/password' do
    it 'returns 200 and stores a digest when the email exists' do
      user
      ActionMailer::Base.deliveries.clear

      expect do
        post '/auth/password', params: { email: user.email }.to_json, headers: unauthenticated_header
      end.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to have_http_status(:ok)
      token = CGI.unescape(ActionMailer::Base.deliveries.last.body.encoded[/token=([^"&\s]+)/, 1])
      expect(user.reload.reset_password_token).not_to eq(token)
      expect(user.reset_password_token).to eq(Devise.token_generator.digest(User, :reset_password_token, token))
    end

    it 'returns 200 and sends nothing when the email is unknown' do
      expect do
        post '/auth/password', params: { email: 'missing@email.com' }.to_json, headers: unauthenticated_header
      end.not_to change { ActionMailer::Base.deliveries.size }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /auth/password' do
    let(:raw) { user.issue_password_reset_token! }

    it 'sets the password, does not issue a JWT, and drops existing sessions' do
      headers = auth_header(user)
      expect(user.allowlisted_jwts.count).to eq(1)

      put '/auth/password',
          params: { reset_password_token: raw, password: 'brand-new-secret' }.to_json,
          headers: unauthenticated_header

      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to be_blank
      expect(user.reload.allowlisted_jwts).to be_empty
      expect(user.reset_password_token).to be_nil
      expect(user.valid_password?('brand-new-secret')).to be(true)

      get "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an expired link' do
      raw
      travel 16.minutes do
        put '/auth/password',
            params: { reset_password_token: raw, password: 'brand-new-secret' }.to_json,
            headers: unauthenticated_header
      end

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.headers['Authorization']).to be_blank
      expect(user.reload.reset_password_token).to be_present
    end

    it 'rejects a reused link' do
      put '/auth/password',
          params: { reset_password_token: raw, password: 'brand-new-secret' }.to_json,
          headers: unauthenticated_header
      put '/auth/password',
          params: { reset_password_token: raw, password: 'another-new-secret' }.to_json,
          headers: unauthenticated_header

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?('brand-new-secret')).to be(true)
    end
  end

  describe 'choosing a password' do
    it 'rejects a short password and one that repeats the email or the organization' do
      user.password = '123123123'
      expect(user).not_to be_valid
      expect(user.errors.where(:password, :too_short)).to be_present

      user.password = 'longlocalpart'
      expect(user).not_to be_valid
      expect(user.errors.where(:password, :denied)).to be_present

      organization = create(:organization, name: 'taverna-longa')
      organization.user.password = 'taverna-longa'
      expect(organization.user).not_to be_valid
    end

    it 'rejects a breached password and accepts one when the service fails' do
      user
      allow_any_instance_of(Pwned::Password).to receive(:pwned_count).and_call_original

      hash = Digest::SHA1.hexdigest('brand-new-secret').upcase
      stub_request(:get, "https://api.pwnedpasswords.com/range/#{hash.first(5)}")
        .to_return(status: 200, body: "#{hash[5..]}:100\r\n")

      user.password = 'brand-new-secret'
      expect(user).not_to be_valid
      expect(user.errors.where(:password, :pwned_password)).to be_present

      stub_request(:get, %r{api\.pwnedpasswords\.com/range/}).to_timeout
      user.password = 'service-down-secret'
      expect(user).to be_valid
    end

    it 'does not call Pwned Passwords on sign-in' do
      create(:user, email: 'signin@email.com', password: 'factory-secret')
      expect_any_instance_of(Pwned::Password).not_to receive(:pwned_count)

      post '/auth/sign_in',
           params: { email: 'signin@email.com', password: 'factory-secret' }.to_json,
           headers: unauthenticated_header

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'staff create' do
    it 'emails a set-password link and does not include a password' do
      organization = create(:organization)
      staff = build(:user, :kitchen, organization:, email: 'staff-new@email.com', password: nil)

      expect { staff.save! }.to change { ActionMailer::Base.deliveries.size }.by(1)
      body = ActionMailer::Base.deliveries.last.body.encoded
      expect(body).to include('token=')
      expect(body).not_to include('Senha gerada')
      expect(staff.reload).to be_confirmed
    end
  end

  describe 'PUT /auth/reset_passwords' do
    it 'requires the current password and keeps the current session' do
      account = create(:organization).user
      headers = auth_header(account)
      put '/auth/reset_passwords',
          params: { reset_params: { password: 'brand-new-secret' } }.to_json,
          headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['code']).to eq('current_password_invalid')

      put '/auth/reset_passwords',
          params: { reset_params: { password: 'brand-new-secret', current_password: 'factory-secret' } }.to_json,
          headers: headers
      expect(response).to have_http_status(:ok)
      expect(account.reload.allowlisted_jwts.count).to eq(1)

      get "/api/v1/users/#{account.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns a password error when the current password is right and the new one is too short' do
      account = create(:organization).user

      put '/auth/reset_passwords',
          params: { reset_params: { password: 'short', current_password: 'factory-secret' } }.to_json,
          headers: auth_header(account)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['code']).to eq('password_too_short')
    end

    it 'changes the password when the session token cannot be read' do
      account = create(:organization).user
      allow_any_instance_of(Warden::JWTAuth::TokenDecoder).to receive(:call).and_wrap_original do |method, *args|
        raise JWT::DecodeError, 'bad' if caller.any? { |line| line.include?('session_revocation') }

        method.call(*args)
      end

      put '/auth/reset_passwords',
          params: { reset_params: { password: 'brand-new-secret', current_password: 'factory-secret' } }.to_json,
          headers: auth_header(account)

      expect(response).to have_http_status(:ok)
      expect(account.reload.valid_password?('brand-new-secret')).to be(true)
      expect(account.allowlisted_jwts).to be_empty
    end
  end

  describe 'PUT /api/v1/users/:id' do
    it 'rejects a password change that does not include the current password' do
      organization = create(:organization)
      staff = create(:user, :kitchen, organization:)

      put "/api/v1/users/#{staff.id}",
          params: { password: 'brand-new-secret' }.to_json,
          headers: auth_header(organization.user)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['code']).to eq('current_password_invalid')
      expect(staff.reload.valid_password?('factory-secret')).to be(true)
    end
  end
end
