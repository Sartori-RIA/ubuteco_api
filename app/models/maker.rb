# frozen_string_literal: true

class Maker < ApplicationRecord
  include AttachmentUrlHelper
  include OrganizationScoped
  include OrganizationReindexable

  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  has_one_attached :logo

  validates :name, :country, presence: true

  has_many :beers, dependent: :destroy

  belongs_to :organization

  def search_data
    {
      name: name,
      country: country,
      organization_id: organization_id
    }
  end

  def logo_url
    url_for_attachment(logo, resize_to_limit: AttachmentUrlHelper::DISPLAY_SIZE)
  end

  def logo_thumbnail_url
    url_for_attachment(logo, resize_to_limit: AttachmentUrlHelper::THUMBNAIL_SIZE)
  end
end
