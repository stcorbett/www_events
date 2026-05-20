Rails.application.routes.draw do

  get "/" => "events#new", as: "root"
  get "theme" => "events#theme"
  get "/events" => "events#index"
  get "/events/checksum" => "events#md5"

  namespace :admin do
    resources :locations do
      member do
        get    'merge',                    to: 'location_merges#new',            as: 'merge'
        get    'merge/:target_id/confirm', to: 'location_merges#confirm',        as: 'merge_confirm'
        post   'merge/:target_id',         to: 'location_merges#execute',        as: 'merge_execute'
        get    'merge/:target_id/result',  to: 'location_merges#result',         as: 'merge_result'
        patch  'merge/:target_id/archive', to: 'location_merges#archive_source', as: 'merge_archive'
        delete 'merge/:target_id/delete',  to: 'location_merges#delete_source',  as: 'merge_delete'
      end
    end
    resources :camps do
      member do
        get    'merge',                    to: 'camp_merges#new',            as: 'merge'
        get    'merge/:target_id/confirm', to: 'camp_merges#confirm',        as: 'merge_confirm'
        post   'merge/:target_id',         to: 'camp_merges#execute',        as: 'merge_execute'
        get    'merge/:target_id/result',  to: 'camp_merges#result',         as: 'merge_result'
        patch  'merge/:target_id/archive', to: 'camp_merges#archive_source', as: 'merge_archive'
        delete 'merge/:target_id/delete',  to: 'camp_merges#delete_source',  as: 'merge_delete'
      end
    end
    resources :departments do
      member do
        get    'merge',                    to: 'department_merges#new',            as: 'merge'
        get    'merge/:target_id/confirm', to: 'department_merges#confirm',        as: 'merge_confirm'
        post   'merge/:target_id',         to: 'department_merges#execute',        as: 'merge_execute'
        get    'merge/:target_id/result',  to: 'department_merges#result',         as: 'merge_result'
        patch  'merge/:target_id/archive', to: 'department_merges#archive_source', as: 'merge_archive'
        delete 'merge/:target_id/delete',  to: 'department_merges#delete_source',  as: 'merge_delete'
      end
    end
    resources :users, only: [:index, :show, :edit, :update]
    get 'export',          to: 'export#index',    as: 'export'
    get 'export/download', to: 'export#download', as: 'export_download'
  end

  resources :events
  resources :derived_locations
  resources :hosted_files
  resources :locations, only: [:index]
  resources :camps, only: [:index]
  resources :departments, only: [:index]
  get "/files/:name", to: "files#show", as: "files"

  put 'locations', to: 'derived_locations#update'
  get "/print", to: "print#show"
  get "/privacy", to: "privacy#show"
  get "/apis", to: "apis#index", as: "apis"

  get 'heart', to: 'hearts#create'
  get 'unheart', to: 'hearts#destroy'

  get 'auth/:provider/callback', to: 'sessions#create'

  # get '/auth/facebook', as: "facebook_login"
  get '/auth/google_oauth2', as: "google_login"

  get 'logout', to: 'sessions#destroy', as: "logout"
  get 'login',  to: 'sessions#new',     as: "login"

  # Email login flow
  get  'login/email',        to: 'email_logins#new',          as: 'email_login'
  post 'login/email',        to: 'email_logins#create'
  get  'login/email/sent',   to: 'email_logins#sent',         as: 'email_login_sent'
  get  'login/email/:token', to: 'email_logins#authenticate', as: 'email_login_authenticate'

end
