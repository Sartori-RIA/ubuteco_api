# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist
  include PgSearch::Model

  acts_as_paranoid

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :confirmable,
         :validatable,
         :trackable,
         :jwt_authenticatable,
         :argon2,
         jwt_revocation_strategy: self

  mount_uploader :avatar, AvatarUploader
  before_validation :set_initial_data, on: :create
  validates :name, :email, presence: true

  belongs_to :organization, optional: true
  accepts_nested_attributes_for :organization, allow_destroy: true

  belongs_to :role

  after_create :send_welcome

  pg_search_scope :search, against: %w[name email]

  def password_salt
    'no salt'
  end

  def password_salt=(new_salt) end

  def send_reset_password_instructions; end

  def generate_code
    loop do
      code = ''
      6.times do
        code += (0..9).to_a.sample.to_s
      end
      break code unless User.find_by(reset_password_token: code)
    end
  end

  def set_initial_data
    return if organization_id.blank? || password.present?

    @generated_password = Devise.friendly_token.first(8)
    self.password = @generated_password
    skip_confirmation!
  end

  def send_welcome
    UserMailer.with(user: self, generated_password: @generated_password).welcome.deliver_now!
  end
end
