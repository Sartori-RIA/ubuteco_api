# frozen_string_literal: true

User.create_with(password: '123123123',
                 name: 'Lucas A. R. Sartori',
                 company_name: 'CookieCode',
                 cnpj: '31.515.296/0001-07')
    .find_or_create_by!(email: 'admin@cookiecode.com.br')
