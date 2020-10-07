class Table < ApplicationRecord
  acts_as_paranoid
  validates :name, presence: true
  validates :chairs, presence: true

  belongs_to :user
end
