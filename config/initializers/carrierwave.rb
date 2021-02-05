require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.fog_credentials = {
        provider: ENV["AWS_PROVIDER"],
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: ENV['AWS_REGION'],
    }
    config.storage = :fog
    config.fog_directory = ENV['AWS_S3_FOLDER']
    config.fog_public = false
    config.fog_attributes = {cache_control: "public, max-age=#{365.days.to_i}"} # optional, defaults to {}
  else
    config.storage = :file
    config.enable_processing = Rails.env.development?
  end
end
