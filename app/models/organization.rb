# frozen_string_literal: true

class Organization < ApplicationRecord
  include AttachmentUrlHelper

  extend Pagy::Search

  enum :operational_status, { open: 0, closed: 1 }

  acts_as_paranoid

  searchkick callbacks: :async

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }
  after_update :close_open_orders_when_kitchen_closes, if: :close_open_orders_on_kitchen_close?

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
    url_for_attachment(logo, resize_to_limit: AttachmentUrlHelper::DISPLAY_SIZE)
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end

  def close_open_orders_on_kitchen_close?
    saved_change_to_operational_status? && closed?
  end

  def close_open_orders_when_kitchen_closes
    closed_count = orders.open.update_all(status: Order.statuses[:closed], updated_at: Time.current)
    Rails.logger.info(
      "[Kitchen] organization=#{id} operational_status=closed auto_closed_orders=#{closed_count}"
    )
  end

  def set_default_theme
    Theme.create(name: 'default',
                 color_footer: 'slate',
                 color_header: 'white',
                 color_sidebar: 'slate',
                 organization: self)
  end
end
