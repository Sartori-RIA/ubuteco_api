# frozen_string_literal: true

json.array! @users, partial: 'api/v1/organizations/users/user', as: :user
