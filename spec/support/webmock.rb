# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: %w[opensearch-node1 opensearch-node2 opensearch]
)
