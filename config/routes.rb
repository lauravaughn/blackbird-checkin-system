Rails.application.routes.draw do
  root 'events#index'
  
  # Authentication routes
  get '/auth/login', to: 'auth#login', as: :login
  delete '/auth/logout', to: 'auth#logout', as: :logout
  
  resources :events do
    member do
      get :dashboard
      post :import_attendees
    end
    
    resources :attendees do
      member do
        get :qr_code
        post :resend_qr_code
      end
    end
  end
  
  # Check-in routes
  get '/check_in/:token', to: 'check_ins#show', as: :check_in
  post '/check_in/:token', to: 'check_ins#create'
  
  # Scanner interface
  get '/scanner/:event_id', to: 'scanner#show', as: :scanner
  post '/scanner/:event_id/scan', to: 'scanner#scan'
  post '/scanner/:event_id/manual', to: 'scanner#manual_check_in'
  
  # API routes for real-time updates
  namespace :api do
    namespace :v1 do
      resources :events, only: [:show] do
        member do
          get :stats
        end
      end
    end
  end
  
  # Health check
  get '/health', to: 'application#health'
end