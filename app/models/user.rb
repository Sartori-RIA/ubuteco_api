# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Whitelist

  acts_as_paranoid

  devise :database_authenticatable, :encryptable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true
  validates :company_name, presence: true
  validates :cnpj, presence: true
  validates_cnpj_format_of :cnpj

  has_many :beer_styles
  has_many :beers
  has_many :makers
  has_many :drinks
  has_many :foods
  has_many :orders
  has_many :dishes
  has_many :tables

  has_one :theme

  after_create(&:set_default_theme)

  def password_salt
    'no salt'
  end

  def password_salt=(new_salt); end

  protected

  def set_default_theme
    Theme.create(name: 'default',
                 color_footer: 'slate',
                 color_header: 'white',
                 color_sidebar: 'slate',
                 rtl: false,
                 user: self)
  end
end
