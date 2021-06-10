# frozen_string_literal: true

json.array! @users, partial: 'api/organizations/users/user', as: :user
