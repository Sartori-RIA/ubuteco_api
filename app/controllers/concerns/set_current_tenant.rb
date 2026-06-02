# frozen_string_literal: true

module SetCurrentTenant
  extend ActiveSupport::Concern

  included do
    before_action :set_current_tenant
    after_action :reset_current_tenant
  end

  private

  def reset_current_tenant
    Current.reset
  end

  def set_current_tenant
    return if current_user.blank?

    Current.user = current_user
    Current.organization = current_user.organization

    return unless current_user.requires_organization?
    return if Current.organization.present?

    head :forbidden
  end
end
