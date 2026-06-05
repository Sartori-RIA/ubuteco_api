# frozen_string_literal: true

SEARCHKICK_MODELS = SearchkickModels.all

module SearchkickTestHelper
  def reindex_searchkick!(*models)
    list = models.presence || SEARCHKICK_MODELS
    Searchkick.callbacks(:inline) do
      list.each { |model| model.reindex(refresh: true) }
    end
  end
end

RSpec.configure do |config|
  config.include SearchkickTestHelper

  config.before(:suite) do
    Searchkick.callbacks(:inline) do
      SEARCHKICK_MODELS.each(&:reindex)
    end
  end
end
