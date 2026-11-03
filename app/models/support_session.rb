# frozen_string_literal: true

class SupportSession < ApplicationRecord
  DURATION = 30.minutes
  RECENT_LIMIT = 50

  belongs_to :actor, class_name: 'User'
  belongs_to :user
  belongs_to :organization
  has_many :support_session_requests, dependent: :delete_all

  validates :reason, presence: true, length: { minimum: 10, maximum: 500 }
  validates :jti, :started_at, :expires_at, presence: true

  scope :open, -> { where(ended_at: nil).where('expires_at > ?', Time.current) }
  scope :recent, -> { order(started_at: :desc).limit(RECENT_LIMIT) }

  def self.open_for(actor)
    open.find_by(actor_id: actor.id)
  end

  def finish!
    return if ended_at.present?

    transaction do
      update!(ended_at: Time.current)
      AllowlistedJwt.where(jti:).delete_all
    end
  end

  def as_list_json
    {
      id:,
      reason:,
      started_at:,
      expires_at:,
      ended_at:,
      actor: { id: actor_id, name: actor.name, email: actor.email },
      user: { id: user_id, name: user.name, email: user.email },
      organization: { id: organization_id, name: organization.name }
    }
  end
end
