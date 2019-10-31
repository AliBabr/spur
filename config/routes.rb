Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          post :sign_in
          post :sign_up
          post :log_out
          post :update_password
          post :update_account
          post :forgot_password
          post :reset_password
        end
        member do
          get :reset
        end
      end
      post '/notifications/toggle_notification', to: 'notifications#toggle_notification'
      resources :places, only: :index
      resources :history, only: [:new, :index]
      end
    end

  root to: "home#index"

end
