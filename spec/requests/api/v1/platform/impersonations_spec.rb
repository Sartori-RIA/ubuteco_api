# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Support impersonation', type: :request do
  let(:organization) { create(:organization) }
  let(:target) { organization.user }
  let(:actor) { create(:user, :super_admin, organization: nil) }
  let(:reason) { 'Reproduce the closed-kitchen bug' }

  def start_session
    post '/api/v1/platform/impersonations',
         params: { user_id: target.id, reason: }.to_json,
         headers: auth_header(actor)
    response.parsed_body
  end

  path '/api/v1/platform/impersonations' do
    post 'Start a support session' do
      tags 'Platform'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: { user_id: { type: :integer }, reason: { type: :string } },
        required: %w[user_id reason]
      }

      response '201', 'created' do
        let(:Authorization) { auth_header(actor)['Authorization'] }
        let(:params) { { user_id: target.id, reason: } }

        run_test! do
          body = response.parsed_body
          expect(body['token']).to be_present
          expect(body.to_json).not_to include('encrypted_password')
          expect(target.reload.encrypted_password).to be_present
        end
      end

      response '403', 'not a super admin' do
        let(:Authorization) { auth_header(target)['Authorization'] }
        let(:params) { { user_id: target.id, reason: } }

        run_test!
      end

      response '422', 'super admin target' do
        let(:Authorization) { auth_header(actor)['Authorization'] }
        let(:other) { create(:user, :super_admin, organization: nil) }
        let(:params) { { user_id: other.id, reason: } }

        run_test!
      end

      response '409', 'already open' do
        let(:Authorization) { auth_header(actor)['Authorization'] }
        let(:params) { { user_id: target.id, reason: } }

        before { start_session }

        run_test!
      end
    end

    get 'List support sessions' do
      tags 'Platform'
      security [Bearer: {}]

      response '200', 'ok' do
        let(:Authorization) { auth_header(actor)['Authorization'] }

        before { start_session }

        run_test! do
          expect(response.parsed_body['data'].first['id']).to be_present
        end
      end
    end
  end

  path '/api/v1/platform/impersonations/{id}' do
    delete 'End a support session' do
      tags 'Platform'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :integer

      response '204', 'ended' do
        let(:Authorization) { auth_header(actor)['Authorization'] }
        let(:id) { start_session['id'] }

        run_test!
      end
    end
  end

  it 'lets the support session create a beer and records the support user' do
    body = start_session
    maker = create(:maker, organization:)
    style = create(:beer_style)
    headers = unauthenticated_header.merge('Authorization' => "Bearer #{body['token']}")

    expect do
      post '/api/v1/beers',
           params: { name: 'Debug Lager', ibu: 20, abv: 5, price: 12, quantity_stock: 4, maker_id: maker.id, beer_style_id: style.id }.to_json,
           headers:
    end.to change(Beer, :count).by(1)

    expect(response).to have_http_status(:created)
    audit = SupportSessionRequest.last
    expect(audit.path).to eq('/api/v1/beers')
    expect(audit.status).to eq(201)
    expect(audit.support_session.actor_id).to eq(actor.id)
  end

  it 'refuses a password change and keeps the digest' do
    body = start_session
    digest = target.encrypted_password
    headers = unauthenticated_header.merge('Authorization' => "Bearer #{body['token']}")

    put "/api/v1/users/#{target.id}",
        params: { password: 'brand-new-secret', current_password: 'factory-secret' }.to_json,
        headers: headers

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body['errors'].first['code']).to eq('impersonation_forbidden')
    expect(target.reload.encrypted_password).to eq(digest)
  end

  it 'rejects the support token after leave and still lets the user sign in' do
    body = start_session
    delete "/api/v1/platform/impersonations/#{body['id']}", headers: auth_header(actor)

    get '/api/v1/beers', headers: unauthenticated_header.merge('Authorization' => "Bearer #{body['token']}")
    expect(response).to have_http_status(:unauthorized)

    post '/auth/sign_in',
         params: { email: target.email, password: 'factory-secret' }.to_json,
         headers: unauthenticated_header
    expect(response).to have_http_status(:ok)
  end

  it 'does not email when the start is rejected' do
    expect do
      post '/api/v1/platform/impersonations',
           params: { user_id: target.id, reason: 'short' }.to_json,
           headers: auth_header(actor)
    end.not_to have_enqueued_mail(SupportSessionMailer, :started)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'emails the target when the session starts' do
    expect { start_session }.to have_enqueued_mail(SupportSessionMailer, :started)
    mail = SupportSessionMailer.with(session: SupportSession.last, recipient: target).started
    expect(mail.body.encoded).to include(reason)
    expect(mail.body.encoded).not_to include('eyJ')
  end
end
