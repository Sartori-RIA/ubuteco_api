# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             path: 'auth',
             path_names: {
               registration: 'sign_up'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }

  namespace :api do
    resources :tables
    resources :foods
    resources :beers
    resources :drinks
    resources :makers
    resources :beer_styles
    resources :kitchens, only: %i[index update]
    resources :profiles, only: %i[update] do
      scope module: :profiles do
        resources :themes, only: %i[show update]
      end
    end
    get 'profiles/me' => 'profiles#me'
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
    resources :wine_styles
    resources :wines
  end
end
