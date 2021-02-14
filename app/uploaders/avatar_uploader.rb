# frozen_string_literal: true

class AvatarUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/#{current_user.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  def default_url(*_args)
    'https://www.flymobi.com.br/images/placeholder-img.jpg'
  end

  def asset_host
    'http://localhost:3000/api'
  end
end
