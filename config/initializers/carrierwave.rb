require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['aws.access_key_id'],
        aws_secret_access_key: ENV['aws.secret_access_key'],
        region: ENV['aws.region'],
    }
    config.storage = :fog
    config.fog_directory = ENV['aws.s3_folder']
    config.fog_public = false
    config.fog_attributes = {cache_control: "public, max-age=#{365.days.to_i}"} # optional, defaults to {}
  else
    config.storage = :file
    config.enable_processing = Rails.env.development?
  end
end
