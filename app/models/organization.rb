# frozen_string_literal: true

class Organization < ApplicationRecord
  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  has_one_attached :logo

  after_create :set_default_theme
  validates :name, :phone, presence: true
  validates :phone, uniqueness: true

  belongs_to :user, optional: true
  accepts_nested_attributes_for :user, allow_destroy: true, limit: 1

  has_many :users, dependent: :delete_all
  has_many :beers, dependent: :delete_all
  has_many :makers, dependent: :delete_all
  has_many :drinks, dependent: :delete_all
  has_many :foods, dependent: :delete_all
  has_many :orders, dependent: :delete_all
  has_many :dishes, dependent: :delete_all
  has_many :tables, dependent: :delete_all
  has_one :theme, dependent: :delete

  def search_data
    {
      name: name,
      phone: phone
    }
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

  def set_default_theme
    Theme.create(name: 'default',
                 color_footer: 'slate',
                 color_header: 'white',
                 color_sidebar: 'slate',
                 organization: self)
  end
end
