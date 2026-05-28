# frozen_string_literal: true


require 'sidekiq/web'

Rails.application.routes.draw do

  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  end


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

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :tables
      resources :foods do
        collection do
          get :options
        end
      end
      resources :beers
      resources :drinks
      resources :makers
      resources :beer_styles do
        collection do
          get 'check/style' => 'beer_styles#style_available?'
        end
      end
      resources :kitchens, except: [:create, :destroy]
      resources :dishes do
        scope module: :dishes do
          resources :ingredients
        end
      end
      resources :orders do
        scope module: :orders do
          resources :items
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
      resources :users do
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
