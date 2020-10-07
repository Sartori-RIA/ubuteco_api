# frozen_string_literal: true

class Theme < ApplicationRecord
  validates :color_header, presence: true
  validates :color_sidebar, presence: true
  validates :color_footer, presence: true
  validates :rtl, default: false

  belongs_to :user, optional: true
end
