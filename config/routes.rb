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
        end
      end

      resources :places, only: :index
    end
  end

  root to: "home#index"

end
