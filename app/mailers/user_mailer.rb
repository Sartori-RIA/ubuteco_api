# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :load_user

  def welcome
    @subject = t('welcome.subject')
    @reset_url = reset_password_url
    mail to: @user.email, subject: @subject
  end

  def password_reset
    @subject = t('password_reset.subject')
    @reset_url = reset_password_url
    mail to: @user.email, subject: @subject
  end

  protected

  def load_user
    @user = params[:user]
  end

  def reset_password_url
    token = params[:reset_token]
    return if token.blank?

    base = ENV.fetch('RESET_PASSWORD_URL', 'http://localhost:3000/reset-password')
    separator = base.include?('?') ? '&' : '?'
    "#{base}#{separator}token=#{URI.encode_www_form_component(token)}"
  end
end
