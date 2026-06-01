# frozen_string_literal: true

class AddLocaleSettingsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    change_table :organizations, bulk: true do |t|
      t.string :locale, default: 'pt-BR', null: false
      t.string :default_currency, default: 'BRL', null: false
      t.string :timezone, default: 'America/Sao_Paulo', null: false
    end
  end
end
