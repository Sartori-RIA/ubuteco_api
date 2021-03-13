# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :load_user

  def welcome
    @subject = t('welcome.subject')
    mail to: @user.email, subject: @subject
  end

  def password_reset_code
    @subject = 'Código de verificação - uButeco'
    mail to: @user.email, subject: @subject
  end

  protected

  def load_user
    @user = params[:user]
    @code = params[:code]
    @generated_password = params[:generated_password]
  end
end
