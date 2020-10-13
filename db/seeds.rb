# frozen_string_literal: true

%w[ADMIN RESTAURANT].each { |role| Role.find_or_create_by!(name: role) }

User.create_with(password: '123123123',
                 name: 'Lucas A. R. Sartori',
                 company_name: 'CookieCode',
                 confirmed_at: Time.zone.now,
                 role_id: Role.find_by(name: 'ADMIN').id,
                 cnpj: '31.515.296/0001-07')
    .find_or_create_by!(email: 'admin@cookiecode.com.br')

User.create_with(password: '123123123',
                 name: 'restaurante',
                 company_name: 'Armazem do malte',
                 confirmed_at: Time.zone.now,
                 cnpj: '44.977.683/0001-07')
    .find_or_create_by!(email: 'teste@email.com')
