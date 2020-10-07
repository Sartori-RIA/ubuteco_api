# frozen_string_literal: true

class ProductPictureUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{current_user.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  def default_url(*_args)
    'https://cookiecode-restaurant_manager.s3.us-east-2.amazonaws.com/defaults/default.jpg'
  end

  def asset_host
    'http://localhost:3000/api'
  end
end
