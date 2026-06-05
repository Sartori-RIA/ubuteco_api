# frozen_string_literal: true

class SearchkickReindex
  class << self
    def all!
      SearchkickModels.all.each(&:reindex)
    end

    def model!(model_name)
      SearchkickModels.find!(model_name).reindex
    end

    def organization!(organization_id)
      org_id = organization_id.to_i
      raise ArgumentError, "organization_id required" if org_id.zero?

      Organization.find(org_id).reindex

      SearchkickModels.all.each do |model|
        next if model == Organization
        next unless model.respond_to?(:reindex_for_organization)

        model.reindex_for_organization(org_id)
      end
    end
  end
end
