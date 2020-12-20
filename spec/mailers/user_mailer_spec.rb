# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let!(:user) { create(:user_customer) }

  describe 'welcome' do
    let!(:mail) do
      described_class.with(user: user).welcome.deliver_now
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Seja bem vindo ao Cookie Restaurant Manager')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['mailer.user_name']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.name)
    end
  end

  describe 'Reset password code' do
    let!(:code) { '123456' }
    let!(:mail) do
      described_class
        .with(
          user: user,
          code: code
        )
        .password_reset_code
        .deliver_now!
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Código de verificação - Cookie Restaurant Manager')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['mailer.user_name']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.name)
    end

    it 'assigns reset code' do
      expect(mail.body.encoded).to match(code)
    end
  end
end
