# frozen_string_literal: true

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{current_user.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  version :thumb do
    process resize_to_fit: [150, 150]
  end

  def default_url(*_args)
    'https://www.flymobi.com.br/images/placeholder-img.jpg'
  end

  def asset_host
    if Rails.env.production?
      'https://api.alertamed.com.br'
    else
      'http://192.168.0.193'
    end
  end
end
