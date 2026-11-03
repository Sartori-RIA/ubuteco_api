# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Platform AI usage', type: :request do
  let!(:organization) { create(:organization, name: 'Bar') }
  let!(:super_admin) { create(:user, :super_admin, organization: nil) }
  let!(:admin) { organization.user }

  it 'returns daily totals to a super admin' do
    AiUsageEvent.create!(
      organization:, feature: 'daily_brief', status: 'ok',
      input_tokens: 8, output_tokens: 3, model: 'claude-haiku-5-5',
      created_at: Time.zone.parse('2026-11-02 10:00:00')
    )

    get api_v1_platform_ai_usage_path, params: { from: '2026-11-02', to: '2026-11-02' },
                                       headers: auth_header(super_admin)

    expect(response).to have_http_status(:ok)
    item = response.parsed_body.fetch('items').first
    expect(item['feature']).to eq('daily_brief')
    expect(item['calls']).to eq(1)
    expect(item['input_tokens']).to eq(8)
  end

  it 'forbids an organization admin' do
    get api_v1_platform_ai_usage_path, headers: auth_header(admin)

    expect(response).to have_http_status(:forbidden)
  end

  it 'rejects a reversed date range' do
    get api_v1_platform_ai_usage_path, params: { from: '2026-11-03', to: '2026-11-01' },
                                       headers: auth_header(super_admin)

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.dig('errors', 0, 'code')).to eq('validation_error')
  end
end
