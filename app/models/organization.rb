# frozen_string_literal: true

class Organization < ApplicationRecord
  acts_as_paranoid

  mount_uploader :logo, LogoUploader

  after_create :set_default_theme
  validates :name, :phone, presence: true
  validates :phone, uniqueness: true

  belongs_to :user, optional: true
  accepts_nested_attributes_for :user, allow_destroy: true, limit: 1

  has_many :users, dependent: :delete_all
  has_many :beers, dependent: :delete_all
  has_many :makers, dependent: :delete_all
  has_many :drinks, dependent: :delete_all
  has_many :foods, dependent: :delete_all
  has_many :orders, dependent: :delete_all
  has_many :dishes, dependent: :delete_all
  has_many :tables, dependent: :delete_all
  has_one :theme, dependent: :delete

  include PgSearch::Model

  pg_search_scope :search, against: %w[name]

  private

  def set_default_theme
    Theme.create(name: 'default',
                 color_footer: 'slate',
                 color_header: 'white',
                 color_sidebar: 'slate',
                 organization: self)
  end
end
