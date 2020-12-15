# frozen_string_literal: true

class Theme < ApplicationRecord
  validates :color_header, :color_sidebar, :color_footer, presence: true
  belongs_to :organization, optional: true
end
