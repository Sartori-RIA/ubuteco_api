# frozen_string_literal: true

module Helpers
  module DeviseHelper
    def generate_code
      loop do
        code = ''
        6.times do
          code += (0..9).to_a.sample.to_s
        end
        break code unless User.find_by(reset_password_token: code)
      end
    end
  end
end
