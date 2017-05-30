Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'
  # get 'home' => 'pages#home'
  
  # API
  scope 'api', as: :api do
    get 'events' => 'events#api_events', as: :events
    get 'workshops' => 'events#api_events', as: :workshops, workshop: true
  end

  # UserSessions
  get 'connexion' => 'user_sessions#new', as: :login
  post 'connexion' => 'user_sessions#create'
  get 'deconnexion' => 'user_sessions#destroy', as: :logout

  # Administration
  namespace :admin do
    root  'pages#home'
    # get 'home' => 'home_carousel_links#home', as: :home
    resources :artists
    resources :articles
    resources :events
    resources :events, path: :workshops, as: :workshops, workshop: true
    resources :festivals
    resources :focus
    resources :galleries do
      get 'images' => 'galleries#images', as: :images
      patch 'images' => 'galleries#images_update'
    end
    resources :home_carousel_links
    resources :info_messages
    resources :pages
    resources :partners
    resources :resources
    resources :users do
      get 'password' => 'users#password', as: :password
      patch 'password' => 'users#password_update'
    end
    delete 'image_ships/:id' => 'galleries#images_delete', as: :image_ship_delete
    get 'get_weezevents' => 'weez_events#get_items', as: :get_weezevents
    get 'weezevents' => 'weez_events#index', as: :weezevents
    post 'weezevents' => 'weez_events#index', update: :forced
    delete 'weezevent/:id' => 'weez_events#delete', as: :weez_event
    # resources :pages
  end

  # Front
  get 'programmation' => 'events#index', as: :events
  get 'activites' => 'events#index', as: :workshops, workshop: true
  get 'articles/:date/*slug' => 'articles#show', as: :article
  get ':category/:date/*slug' => 'events#show', constraints: proc { |req| req.params[:category].in? Event.categories_urlized }, as: :event
  get ':category/*slug' => 'events#show', constraints: proc { |req| req.params[:category].in? Event.categories_urlized(:workshop) }, as: :workshop, workshop: true
  get 'festival/*slug' => 'festivals#show', as: :festival

  # La-Fabrique redirection
  get '/la-fabrique' => 'pages#redirect'
  get '/articles/:id' => 'pages#redirect'
  get '/le-bureau-de-tendances' => 'pages#redirect'
  get '/le-laboratoire-d-idees' => 'pages#redirect'
  get '/le-laboratoire-d-idees/:id/*slug' => 'pages#redirect'
  get '/l-atelier' => 'pages#redirect'
  get '/l-atelier/:id/*slug' => 'pages#redirect'
  get '/la-cagnotte' => 'pages#redirect'
  get '/profil' => 'pages#redirect'

  # Pages
  get '*slug' => 'pages#show', as: :page
end
