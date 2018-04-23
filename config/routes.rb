Rails.application.routes.draw do

  get "/" => "events#new", as: "root"
  get "theme" => "events#theme"
  get "/events" => "events#index"

  resources :events
  resources :locations
  put 'locations', to: 'locations#update'

  get 'heart', to: 'hearts#create'
  get 'unheart', to: 'hearts#destroy'

  get 'auth/:provider/callback', to: 'sessions#create'

  get '/auth/facebook', as: "facebook_login"
  get '/auth/google_oauth2', as: "google_login"

  get 'logout', to: 'sessions#destroy', as: "logout"
  get 'login', to: 'sessions#new', as: "login"

end
