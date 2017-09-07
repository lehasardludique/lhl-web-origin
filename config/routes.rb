Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'
  # get 'home' => 'pages#home'
  
  # API
  scope 'api', as: :api do

    # Select2 Ajax Remote
    scope 's2', as: :s2 do
      get 'resources(/:scope)' => 'resources#api_s2_resources', as: :resources
    end

    # DataTable Ajax Remote
    scope 'dt', as: :dt do
      get 'resources' => 'resources#api_dt_resources', as: :resources
      get 'events' => 'events#api_dt_events', as: :events
      get 'workshops' => 'events#api_dt_events', workshop: true, as: :workshops
    end

    # LHL
    get 'events' => 'events#api_events', as: :events
    get 'workshops' => 'events#api_events', workshop: true, as: :workshops
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
    resources :events, as: :events
    resources :events, path: :workshops, workshop: true, as: :workshops
    resources :festivals
    resources :focus
    resources :galleries do
      get 'images' => 'galleries#images', as: :images
      patch 'images' => 'galleries#images_update'
    end
    resources :home_carousel_links
    resources :info_messages
    resources :menu_links
    resources :pages
    get 'partners_page' => 'partners#page', as: :partners_page
    patch 'partners_page' => 'partners#page_update'
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
  get 'les-partenaires' => 'pages#partners', as: :partners
  get 'activites' => 'events#index', workshop: true, as: :workshops
  get 'articles/:date/*slug' => 'articles#show', as: :article
  get ':category/:date/*slug' => 'events#show', constraints: proc { |req| req.params[:category].in? Event.categories_urlized }, as: :event
  get ':category/*slug' => 'events#show', constraints: proc { |req| req.params[:category].in? Event.categories_urlized(:workshop) }, workshop: true, as: :workshop
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
