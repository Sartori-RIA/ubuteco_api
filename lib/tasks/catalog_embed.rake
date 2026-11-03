# frozen_string_literal: true

namespace :catalog do
  namespace :embed do
    desc 'Embed catalog products for one organization. Usage: bin/rails catalog:embed:organization[ORG_ID]'
    task :organization, [:organization_id] => :environment do |_task, args|
      abort 'Usage: bin/rails catalog:embed:organization[ORG_ID]' if args[:organization_id].blank?

      organization = Organization.find(args[:organization_id])
      Current.organization = organization
      Catalog::EmbeddingText::MODELS.each_value do |model|
        model.where(organization_id: organization.id).find_each do |record|
          EmbedProductJob.new.perform(model.name, record.id, organization.id)
        end
      end
      puts "Embedded catalog for organization #{organization.id}"
    ensure
      Current.reset
    end
  end
end
