# frozen_string_literal: true

class ReindexJob
  include Sidekiq::Job
  sidekiq_options queue: :searchkick, retry: 1, dead: false

  # record_id present  → single-record reindex
  # organization_id    → org-scoped batch (rake / maintenance)
  # neither            → refused (use searchkick:reindex:all with env guard)
  def perform(model_name, record_id = nil, organization_id = nil)
    model = model_name.constantize

    if record_id.present?
      reindex_record(model, record_id)
    elsif organization_id.present?
      reindex_organization(model, organization_id)
    else
      raise ArgumentError, "Full-class reindex disabled. Use rake searchkick:reindex:all with ALLOW_FULL_SEARCH_REINDEX=1"
    end
  ensure
    Current.reset
  end

  private

  def reindex_record(model, record_id)
    record = model.find_by(id: record_id)
    record&.reindex
  end

  def reindex_organization(model, organization_id)
    Current.organization = Organization.find_by(id: organization_id)

    if model.respond_to?(:reindex_for_organization)
      model.reindex_for_organization(organization_id)
    elsif model == Organization
      model.where(id: organization_id).reindex
    else
      raise ArgumentError, "#{model.name} cannot be reindexed by organization_id"
    end
  end
end
