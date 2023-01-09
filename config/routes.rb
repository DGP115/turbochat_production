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
  # Custom routes for users
  get 'user/:id', to: 'users#show', as: 'user'

  # Routes for Rooms
  resources :rooms do
    resources :messages
    #  This is cool.  Recall that the search of rooms may return a colleciton of rooms.
    #  This statement tells rails how to route thet collection
    collection do
      post :search
    end
  end

  get 'roomslist', to: 'rooms#list'
  get 'rooms_admin', to: 'rooms#admin'
  # The as: here creates the path the way we want.  e.g. it creates join_room_path(room)
  get 'rooms/join/:id', to: 'rooms#join', as: 'join_room'
  get 'rooms/leave/:id', to: 'rooms#leave', as: 'leave_room'
end
