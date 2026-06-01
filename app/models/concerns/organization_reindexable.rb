# frozen_string_literal: true

module OrganizationReindexable
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_organization_reindex_job, unless: -> { Rails.env.test? }
  end

  private

  def enqueue_organization_reindex_job
    org_id = respond_to?(:organization_id) ? organization_id : nil
    ReindexJob.perform_async(self.class.name, org_id)
  end
end
