# frozen_string_literal: true

Rails.application.routes.draw do
  # Defines the root path route ("/")
  root 'pages#home'

  get 'about', to: 'pages#about'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # To support Devise for User management
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Routes for Rooms
  resources :rooms do
    resources :messages
  end

  get 'roomslist', to: 'rooms#list'
  get 'rooms_admin', to: 'rooms#admin'

  # Custom routes for users
  get 'user/:id', to: 'users#show', as: 'user'
end
