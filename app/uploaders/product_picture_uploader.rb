# frozen_string_literal: true

class ProductPictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  version :thumb do
    process resize_to_fit: [150, 150]
  end

  def default_url(*_args)
    'http://lorempixel.com.br/500/400/?1'
  end

  def asset_host
    if Rails.env.production?
      'https://ibuteco.herokuapp.com/'
    else
      'http://localhost:3000'
    end
  end
end
