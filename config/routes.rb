Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#wip'
  get 'home' => 'pages#home'
  
  # UserSessions
  get 'connexion' => 'user_sessions#new', as: :login
  post 'connexion' => 'user_sessions#create'
  get 'deconnexion' => 'user_sessions#destroy', as: :logout

  # Administration
  namespace :admin do
    root  'pages#home'
    resources :users do
      get 'password' => 'users#password', as: :password
      patch 'password' => 'users#password_update'
    end
    # get 'home' => 'home_carousel_links#home', as: :home
    resources :home_carousel_links
    resources :resources
    resources :pages
    resources :articles
    resources :galleries do
      get 'images' => 'galleries#images', as: :images
      patch 'images' => 'galleries#images_update'
    end
    delete 'image_ships/:id' => 'galleries#images_delete', as: :image_ship_delete
    # resources :pages
  end

  # Articles
  get 'articles/:date/*slug' => 'articles#show', as: :article

  # La-Fabrique redirection
  get '/la-fabrique' => 'pages#redirect'
  get '/le-bureau-de-tendances' => 'pages#redirect'
  get '/le-laboratoire-d-idees' => 'pages#redirect'
  get '/le-laboratoire-d-idees/:id/*' => 'pages#redirect'
  get '/l-atelier' => 'pages#redirect'
  get '/l-atelier/:id/*' => 'pages#redirect'
  get '/la-cagnotte' => 'pages#redirect'
  get '/profil' => 'pages#redirect'

  # Pages
  get '*slug' => 'pages#show', as: :page
end
