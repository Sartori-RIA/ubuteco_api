# frozen_string_literal: true

json.array! @users, partial: 'api/v1/users/user', as: :user
