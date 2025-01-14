Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  # Profile routes
  resource :profile, only: [:show]
  
  # Admin routes
  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    root to: 'dashboard#index'
    resources :users
  end
  
  # Defines the root path route ("/")
  root "home#index"
end
