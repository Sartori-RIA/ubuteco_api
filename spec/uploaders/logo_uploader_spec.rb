# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LogoUploader, type: :uploader do
  let!(:organization) { create(:organization) }
  let!(:uploader) { described_class.new(organization, :avatar) }

  before do
    described_class.enable_processing = true
    FileSpecHelper.image { |f| uploader.store!(f) }
  end

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  describe "#URLS" do
    it 'has default url' do
      expect(uploader.default_url).to eq('https://s3.us-east-2.amazonaws.com/ibuteco.cookiecode.com.br/uploads/default.png')
    end
    it 'has base url to ' do
      expect(uploader.asset_host).to eq('http://192.168.0.193')
    end
    it 'has base url to production' do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(uploader.asset_host).to eq('https://ibuteco.herokuapp.com/')
    end
  end

  it "has the correct format" do
    expect(uploader.extension_whitelist).to eq(%w[jpg jpeg gif png])
  end

  it 'in the folder' do
    expect(uploader.store_dir.to_s).to match("uploads/#{organization.class.to_s.underscore}/avatar/#{organization.id}")
  end
end
