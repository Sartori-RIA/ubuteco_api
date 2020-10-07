# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  describe '#POST /sign_up' do
    it 'should create new account' do
    end

    context 'should throw error' do
      it 'with wrong data' do
      end
      it 'when CNPJ already taken' do
      end
      it 'when Email already taken' do
      end
    end
  end
end
