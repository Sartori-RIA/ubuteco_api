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
         jwt_revocation_strategy: self

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

  def generate_code
    loop do
      code = ''
      6.times do
        code += (0..9).to_a.sample.to_s
      end
      break code unless User.find_by(reset_password_token: code)
    end
  end

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

    @generated_password = Devise.friendly_token.first(8)
    self.password = @generated_password
    skip_confirmation!
  end

  def send_welcome
    return if Rails.env.development?

    UserMailer.with(user: self, generated_password: @generated_password).welcome.deliver_now!
  end
end
