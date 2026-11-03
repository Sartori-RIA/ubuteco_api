# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let!(:user) { create(:user, :customer) }

  describe 'welcome' do
    let!(:mail) do
      described_class.with(user: user).welcome.deliver_now
    end

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('welcome.subject'))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['MAILER_USER_NAME']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.name)
    end
  end

  describe 'password reset' do
    let!(:mail) do
      described_class.with(user: user, reset_token: 'raw-token').password_reset.deliver_now!
    end

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('password_reset.subject'))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['MAILER_USER_NAME']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.name)
    end

    it 'assigns the reset link' do
      expect(mail.body.encoded).to include('token=raw-token')
    end
  end
end
