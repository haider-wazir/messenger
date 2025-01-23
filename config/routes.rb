Rails.application.routes.draw do
  root 'home#index'
  
  namespace :api do
    namespace :v1 do
      post '/auth/register', to: 'auth#register'
      post '/auth/login', to: 'auth#login'
      delete '/auth/logout', to: 'auth#logout'
      get '/auth/me', to: 'auth#me'
      
      resources :users, only: [:index]
      
      resources :messages, only: [:index, :create, :destroy] do
        collection do
          post :mark_read
          get :unread_counts
        end
      end
    end
  end
  
  mount ActionCable.server => '/cable'
end
