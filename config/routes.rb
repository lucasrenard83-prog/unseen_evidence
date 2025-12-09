Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "uikit" => "pages#uikit"

  resources :games, only: [:index, :new, :create, :destroy] do
    resources :messages, only: [:create]
  end
  resources :rooms, only: [:show] do
    member do
      post :unlock_trapdoor
    end
  end

  post "games/:id/confront", to: "games#confront", as: "confront_game"

  # Defines the root path route ("/")
  # root "posts#index"
end
