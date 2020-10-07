require 'rails_helper'

RSpec.describe Theme, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:color_header) }
    it { is_expected.to validate_presence_of(:color_sidebar) }
    it { is_expected.to validate_presence_of(:color_footer) }
  end
end
