# frozen_string_literal: true

class ReindexJob
  include Sidekiq::Job
  queue_as :default
  sidekiq_options retry: 1, dead: false

  def perform(model_name, organization_id = nil)
    Current.organization = Organization.find_by(id: organization_id) if organization_id.present?

    model = model_name.constantize
    if organization_id.present? && model.respond_to?(:reindex_for_organization)
      model.reindex_for_organization(organization_id)
    else
      model.reindex
    end
  ensure
    Current.reset
  end
end
