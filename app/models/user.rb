# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  acts_as_paranoid

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :confirmable, :lockable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  mount_uploader :avatar, AvatarUploader

  validates :name, :email, presence: true

  belongs_to :organization, optional: true
  accepts_nested_attributes_for :organization, allow_destroy: true

  belongs_to :role

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

  def send_welcome
    UserMailer.with(user: self).welcome.deliver_now!
  end
end
