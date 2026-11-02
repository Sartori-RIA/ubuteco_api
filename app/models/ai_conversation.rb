# frozen_string_literal: true

class AiConversation < ApplicationRecord
  acts_as_paranoid

  RETENTION = 90.days

  belongs_to :organization
  belongs_to :user
  has_many :ai_messages, dependent: :delete_all

  def self.purge_expired!(older_than: RETENTION.ago)
    with_deleted.where(updated_at: ...older_than).find_each do |conversation|
      conversation.ai_messages.delete_all
      conversation.really_destroy!
    end
  end
end
