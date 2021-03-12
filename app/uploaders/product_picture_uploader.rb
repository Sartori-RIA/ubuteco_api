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
    'https://s3.us-east-2.amazonaws.com/ibuteco.cookiecode.com.br/uploads/default.png'
  end

  def asset_host
    if Rails.env.production?
      'https://ibuteco.herokuapp.com/'
    else
      'http://192.168.0.193'
    end
  end
end
