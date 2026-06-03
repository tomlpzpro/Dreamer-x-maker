Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :projects
  resource :profile, only: [:show, :edit, :update]

  resources :ai_chats, only: [:show] do
    post :messages, on: :member, action: :create_message
    post :generer_visuel, on: :member
  end
end
