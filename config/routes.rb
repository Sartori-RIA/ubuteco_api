# frozen_string_literal: true


require 'sidekiq/web'
require 'jwt_authentication'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  Sidekiq::Web.use JwtAuthentication
  mount Sidekiq::Web => '/sidekiq'


  devise_for :users,
             path: 'auth',
             defaults: { format: :json },
             path_names: {
               registration: 'sign_up',
               confirmation: 'confirmations'
             },
             controllers: {
               confirmations: 'confirmations',
               unlocks: 'unlocks',
               passwords: 'passwords',
               sessions: 'sessions',
               registrations: 'registrations'
             }
  post 'auth/code' => 'code_validations#create'
  put 'auth/reset_passwords' => 'reset_passwords#update'

  namespace :api do
    namespace :v1 do
      resources :tables
      resources :foods
      resources :beers
      resources :drinks
      resources :makers
      resources :beer_styles do
        collection do
          get 'check/style' => 'beer_styles#style_available?'
        end
      end
      resources :kitchens, only: %i[index update]
      resources :dishes do
        scope module: :dishes do
          resources :ingredients, except: :show
        end
      end
      resources :orders do
        scope module: :orders do
          resources :items, except: :show
        end
      end
      resources :organizations, except: :create do
        collection do
          get 'check/phone' => 'organizations#phone_available?'
        end
        scope module: :organizations do
          resources :themes, except: :destroy
          resources :users, only: :index
        end
      end
      resources :customers, only: :index
      resources :users, except: :index do
        collection do
          get 'check/email' => 'users#email_available?'
        end
      end
      resources :wine_styles do
        collection do
          get 'check/style' => 'wine_styles#style_available?'
        end
      end
      resources :wines
      resources :roles
    end
    mount ActionCable.server => '/cable'
  end
end
