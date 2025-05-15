Rails.application.routes.draw do

  get "/" => "events#new", as: "root"
  get "theme" => "events#theme"
  get "/events" => "events#index"
  get "/events/checksum" => "events#md5"

  namespace :admin do
    resources :locations
  end

  resources :events
  resources :derived_locations
  resources :hosted_files
  get "/files/:name", to: "files#show", as: "files"

  put 'locations', to: 'derived_locations#update'
  get "/print", to: "print#show"
  get "/privacy", to: "privacy#show"

  get 'heart', to: 'hearts#create'
  get 'unheart', to: 'hearts#destroy'

  get 'auth/:provider/callback', to: 'sessions#create'

  get '/auth/facebook', as: "facebook_login"
  get '/auth/google_oauth2', as: "google_login"

  get 'logout', to: 'sessions#destroy', as: "logout"
  get 'login', to: 'sessions#new', as: "login"

end
