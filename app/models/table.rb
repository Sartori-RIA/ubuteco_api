# frozen_string_literal: true

class Table < ApplicationRecord
  acts_as_paranoid
  validates :name, :chairs, presence: true

  belongs_to :user
end
