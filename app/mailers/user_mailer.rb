# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :load_user

  def welcome
    @subject = 'Seja bem vindo ao Cookie Restaurant Manager'
    mail to: @user.email, subject: @subject
  end

  def password_reset_code
    @subject = 'Código de verificação - Cookie Restaurant Manager'
    mail to: @user.email, subject: @subject
  end

  def confirmation; end

  protected

  def load_user
    @user = params[:user]
    @code = params[:code]
  end
end
