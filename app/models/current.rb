# frozen_string_literal: true

# Request-scoped tenant context. Set in SetCurrentTenant after auth;
# cleared by after_action on ApplicationController.
# Jobs and console must set Current explicitly or pass organization_id.
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :organization

  def organization_id
    organization&.id
  end
end
