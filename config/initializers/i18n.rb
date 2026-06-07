# frozen_string_literal: true

Rails.application.config.i18n.available_locales = [:'pt-BR', :en, :'en-CA', :es, :fr, :'fr-CA']
Rails.application.config.i18n.default_locale = :'pt-BR'
Rails.application.config.i18n.fallbacks = { 'en-CA': [:en], fr: [:en], 'fr-CA': [:fr, :en] }
