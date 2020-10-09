RSpec.configure do |config|
  config.after(:all) do
    path = Rails.root.join('spec', 'support', 'uploads')
    FileUtils.rm_rf(Dir[path]) if Rails.env.test?
  end
end
# put logic in this file or initializer/carrierwave.rb
if defined?(CarrierWave)
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?

    klass.class_eval do
      def cache_dir
        Rails.root.join('spec', 'support', 'uploads', 'tmp')
      end

      def store_dir
        Rails.root.join('spec', 'support', 'uploads',
                        model.class.to_s.underscore, mounted_as.to_s, model.id.to_s)
      end
    end
  end
end
