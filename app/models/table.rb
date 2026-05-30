# frozen_string_literal: true

class Table < ApplicationRecord
  include OrganizationScoped

  acts_as_paranoid

  validates :name, :chairs, presence: true

  belongs_to :organization
end
