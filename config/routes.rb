Rails.application.routes.draw do

  get "/" => "events#new"
  get "theme" => "events#theme"
  get "/events" => "events#index"

  resources :events

end
