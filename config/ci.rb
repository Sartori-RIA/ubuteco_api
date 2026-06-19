# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step 'Setup', 'bin/setup --skip-server'

  step 'Style: Ruby', 'bin/rubocop'

  step 'Security: Gem audit', 'bin/bundler-audit'
  step 'Security: Brakeman code analysis', 'bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error'
  step 'Tests: RSpec', 'bundle exec rspec'
  step 'OpenAPI: drift check', 'bundle exec rake openapi:drift_check'
  step 'Docs: plan status drift check', 'bin/plans_drift_check'
  step 'Tests: Seeds', 'env RAILS_ENV=test bin/rails db:seed:replant'

  # Optional: Run system tests
  # step "Tests: System", "bin/rails test:system"

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
