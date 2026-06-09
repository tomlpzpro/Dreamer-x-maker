Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  # Page listing every published project (those still looking for a maker)
  get "published_projects", to: "pages#published_projects", as: :published_projects

  resources :projects do
    # A maker matches a project (creates the match) or says it is not for him
    member do
      post :match, to: "maker_projects#create"
      post :dismiss, to: "maker_projects#dismiss"

      # Le dreamer accepte une candidature d'un maker
      # patch (et non post) --> on modifie un enregistrement existant
      patch :approve, to: "maker_projects#approve"
      # Le dreamer refuse une candidature d'un maker
      patch :reject, to: "maker_projects#reject"

      # Le maker indique que le projet est réalisé
      patch :mark_made, to: "maker_projects#mark_made"
      # Le dreamer confirme la réception : formulaire (photo + note) puis livraison
      get :delivery, to: "maker_projects#delivery"
      patch :mark_delivered, to: "maker_projects#mark_delivered"
    end
  end
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
