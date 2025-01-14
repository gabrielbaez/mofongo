Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "blog_posts#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }
  
  # Profile routes
  resources :profiles, only: [:show], path: 'users' do
    resource :follow, only: [:create, :destroy]
  end
  
  # Admin routes
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    root to: 'dashboard#index'
    
    resources :users do
      member do
        post :make_admin
        post :make_moderator
      end
    end
    
    resources :blog_categories
    resources :blog_posts do
      member do
        post :publish
        post :unpublish
        post :feature
        post :unfeature
      end
    end
    
    resources :blog_series
    resources :tags do
      member do
        get :merge
        post :merge
      end
      collection do
        get :search
      end
    end
    
    get 'tags/search', to: 'tags#search'
    post 'direct_uploads', to: 'direct_uploads#create'
    resources :achievements
    resources :comments
    resources :gallery_images, except: [:new, :create] do
      collection do
        get :search
      end
    end
  end
  
  # Blog routes for public viewing
  resources :blog_posts, only: [:index, :show], path: 'blog' do
    resources :comments, only: [:create, :update, :destroy] do
      member do
        post :upvote
        post :downvote
      end
      resources :replies, only: [:create, :destroy]
    end
    
    collection do
      get :feed, defaults: { format: 'rss' }
      get 'archive/:year(/:month(/:day))', to: 'blog_posts#archive', as: :archive,
        constraints: {
          year: /\d{4}/,
          month: /\d{1,2}/,
          day: /\d{1,2}/
        }
    end
  end
  resources :blog_categories, only: [:show], path: 'categories'
  resources :blog_series, only: [:index, :show], path: 'series'
  resources :tags, only: [:show], path: 'tags'
  
  # Comment votes
  resources :comments, only: [] do
    resource :vote, only: [:create, :destroy]
  end
  
  # Subscriptions
  resources :subscriptions, only: [:create, :new] do
    get :confirm, on: :member
    get :unsubscribe, on: :member
    get :success, on: :collection
    get :cancel, on: :collection
  end
  
  get 'feed', to: 'blog_posts#feed', defaults: { format: 'rss' }
  
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  
  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end
  
  resource :feed, only: [:show]
  resource :leaderboard, only: [:show]
end
