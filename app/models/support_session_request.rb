# frozen_string_literal: true

class SupportSessionRequest < ApplicationRecord
  belongs_to :support_session

  validates :http_method, :path, :status, presence: true
end
