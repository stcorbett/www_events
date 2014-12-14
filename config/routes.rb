Rails.application.routes.draw do

  get "/" => "events#new", as: "root"
  get "theme" => "events#theme"
  get "/events" => "events#index"

  resources :events

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy', as: "logout"
  get '/auth/facebook', as: "facebook_login"
end
