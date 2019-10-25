Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create, :destroy]
      resources :users do
        collection do
          post :sign_in
          post :sign_up
          post :log_out
          post :update_password
          post :forgot_password
          post :reset_password
        end
        member do
          get :reset
        end
      end

      resources :places, only: :index
      resources :history, only: :index
    end
  end

  root to: "home#index"

end
