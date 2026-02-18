# frozen_string_literal: true

class Maker < ApplicationRecord
  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  has_one_attached :logo

  validates :name, :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :organization

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    { name: name }
  end

  def logo_url
    if logo.attached?
      Rails.application.routes.url_helpers.url_for(
        logo.variant(resize_to_limit: [100, 100]).processed
      )
    else
      "#{Rails.application.routes.default_url_options[:protocol] || 'http'}://" \
        "#{Rails.application.routes.default_url_options[:host]}" \
        "#{Rails.application.routes.default_url_options[:port] ? ":#{Rails.application.routes.default_url_options[:port]}" : ""}" \
        "#{ActionController::Base.helpers.asset_path('images/default.png')}"
    end
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
