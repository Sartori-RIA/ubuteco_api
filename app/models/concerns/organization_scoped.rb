# frozen_string_literal: true

module OrganizationScoped
  extend ActiveSupport::Concern

  included do
    scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  end

  class_methods do
    def reindex_for_organization(organization_id)
      return reindex if organization_id.blank?

      for_organization(organization_id).reindex
    end
  end
end
