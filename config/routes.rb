Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :projects
  resource :profile, only: [:show, :edit, :update]

  get :dashboard, to: "dashboards#show", as: :dashboard

  # Public maker profile page (portfolio of delivered creations)
  resources :makers, only: [:show]

  # AI chat pages: show a conversation and let the user post a message
  resources :llm_chats, only: [] do
    resources :llm_messages, only: [:create]
    post :generate_visual, on: :member
  end

  # Match chat pages: a dreamer and a maker talk together about a project
  resources :match_chats, only: [:index, :show] do
    post :messages, on: :member, action: :create_message
  end

end
