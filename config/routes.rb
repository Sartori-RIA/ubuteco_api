# frozen_string_literal: true

Rails.application.routes.draw do
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
    resources :tables do
      collection do
        get 'search' => 'tables#search'
      end
    end
    resources :foods do
      collection do
        get 'search' => 'foods#search'
      end
    end
    resources :beers do
      collection do
        get 'search' => 'beers#search'
      end
    end
    resources :drinks do
      collection do
        get 'search' => 'drinks#search'
      end
    end
    resources :makers do
      collection do
        get 'search' => 'makers#search'
      end
    end
    resources :beer_styles
    resources :kitchens, only: %i[index update]
    resources :dishes do
      collection do
        get 'search' => 'dishes#search'
      end
      scope module: :dishes do
        resources :ingredients, except: :show
      end
    end
    resources :orders do
      collection do
        get 'search' => 'orders#search'
      end
      scope module: :orders do
        resources :items, except: :show
      end
    end
    resources :organizations, except: :create do
      collection do
        get 'search' => 'organizations#search'
      end
      scope module: :organizations do
        resources :themes, except: :delete
      end
    end
    resources :users
    resources :wine_styles
    resources :wines do
      collection do
        get 'search' => 'wines#search'
      end
    end
    mount ActionCable.server => '/cable'
  end
end
