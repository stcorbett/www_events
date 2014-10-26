Rails.application.routes.draw do

  get "/" => "events#new"
  get "theme" => "events#theme"

  resources :events

end
