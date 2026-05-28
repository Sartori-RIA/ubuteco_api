# frozen_string_literal: true

module AttachmentUrlHelper
  extend ActiveSupport::Concern

  # List cards (~200px display; 2× for retina)
  THUMBNAIL_SIZE = [400, 400].freeze
  # Detail / show pages
  DISPLAY_SIZE = [1200, 1200].freeze
  # Profile avatars, small chrome
  AVATAR_SIZE = [256, 256].freeze

  private

  def url_for_attachment(attachment, resize_to_limit: DISPLAY_SIZE)
    return default_attachment_url unless attachment.attached?

    if image_variants_enabled?
      attachment_variant_url(attachment, resize_to_limit)
    else
      Rails.application.routes.url_helpers.url_for(attachment)
    end
  rescue StandardError => e
    Rails.logger.warn("[AttachmentUrlHelper] #{e.class}: #{e.message}")
    attachment.attached? ? Rails.application.routes.url_helpers.url_for(attachment) : default_attachment_url
  end

  def attachment_variant_url(attachment, resize_to_limit)
    Rails.application.routes.url_helpers.url_for(
      attachment.variant(resize_to_limit: resize_to_limit).processed
    )
  end

  def image_variants_enabled?
    return false if Rails.application.config.active_storage.variant_processor == :disabled

    defined?(ImageProcessing)
  end

  def default_attachment_url
    host = Rails.application.routes.default_url_options
    protocol = host[:protocol] || 'http'
    hostname = host[:host]
    port = host[:port]
    port_segment = port ? ":#{port}" : ''

    "#{protocol}://#{hostname}#{port_segment}#{ActionController::Base.helpers.asset_path('images/default.png')}"
  end
end
