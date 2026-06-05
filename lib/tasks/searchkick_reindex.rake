# frozen_string_literal: true

namespace :searchkick do
  namespace :reindex do
    desc "Reindex all Searchkick models (maintenance). Requires ALLOW_FULL_SEARCH_REINDEX=1"
    task all: :environment do
      unless ENV["ALLOW_FULL_SEARCH_REINDEX"] == "1"
        abort "Refusing full reindex. Set ALLOW_FULL_SEARCH_REINDEX=1 to continue."
      end

      SearchkickReindex.all!
      puts "Reindexed #{SearchkickModels.all.map(&:name).join(', ')}"
    end

    desc "Reindex one model, e.g. bin/rails searchkick:reindex:model[Beer]"
    task :model, [:name] => :environment do |_task, args|
      abort "Usage: bin/rails searchkick:reindex:model[Beer]" if args[:name].blank?

      SearchkickReindex.model!(args[:name])
      puts "Reindexed #{args[:name]}"
    end

    desc "Reindex all indexed records for an organization"
    task :organization, [:organization_id] => :environment do |_task, args|
      abort "Usage: bin/rails searchkick:reindex:organization[ORG_ID]" if args[:organization_id].blank?

      SearchkickReindex.organization!(args[:organization_id])
      puts "Reindexed organization #{args[:organization_id]}"
    end
  end
end
