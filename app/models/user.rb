# frozen_string_literal: true

class User < ApplicationRecord
  include AttachmentUrlHelper
  include Devise::JWT::RevocationStrategies::Allowlist
  include OrganizationScoped

  extend Pagy::Search

  searchkick callbacks: :async

  after_create :send_welcome

  acts_as_paranoid

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :confirmable,
         :validatable,
         :trackable,
         :jwt_authenticatable,
         :argon2,
         :pwned_password,
         jwt_revocation_strategy: self

  include PasswordPolicy

  has_one_attached :avatar
  before_validation :set_initial_data, on: :create
  validates :name, :email, presence: true

  belongs_to :organization, optional: true
  accepts_nested_attributes_for :organization, allow_destroy: true

  belongs_to :role

  ORG_SCOPED_ROLES = %w[ADMIN KITCHEN WAITER CASH_REGISTER].freeze

  def requires_organization?
    ORG_SCOPED_ROLES.include?(role.name)
  end

  def password_salt
    'no salt'
  end

  def password_salt=(new_salt) end

  def send_reset_password_instructions; end

  def search_data
    {
      name: name,
      email: email,
      organization_id: organization_id,
      role_name: role&.name
    }
  end

  def avatar_url
    url_for_attachment(avatar, resize_to_limit: AttachmentUrlHelper::AVATAR_SIZE)
  end

  private

  def set_initial_data
    return if organization_id.blank? || password.present?

    self.password = SecureRandom.base58(32)
    skip_confirmation!
    @issue_set_password_link = true
  end

  def send_welcome
    return if Rails.env.development?

    token = issue_password_reset_token! if @issue_set_password_link
    UserMailer.with(user: self, reset_token: token).welcome.deliver_now!
  end
end
