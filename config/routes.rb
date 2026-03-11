Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end
  root "dashboard#index"

  resources :reports do
    resources :comments, only: [ :create, :destroy ]
    member do
      patch :assign
      patch :start_work
      patch :resolve
      patch :close
      patch :reopen
      get :download_pdf
    end
    collection do
      get :export_csv
    end
  end

  resources :locations, only: [ :index ] do
    member do
      get :qr_code
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
