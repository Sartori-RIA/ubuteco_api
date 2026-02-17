# frozen_string_literal: true

class ReindexJob
  include Sidekiq::Job
  queue_as :default
  sidekiq_options retry: 1, dead: false

  def perform(model_name)
    model = model_name.constantize
    model.reindex
  end
end
