Rails.application.routes.draw do
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "sign_in",
               sign_out: "sign_out"
             },
             skip: [:registrations, :passwords]

  as :user do
    get "sign_up", to: "devise/registrations#new", as: :new_user_registration
    post "sign_up", to: "devise/registrations#create", as: :user_registration
  end

  devise_scope :user do
    get "forgot", to: "devise/passwords#new", as: :new_user_password
    post "forgot", to: "devise/passwords#create", as: :user_password
    get "forgot/edit", to: "devise/passwords#edit", as: :edit_user_password
    patch "forgot", to: "devise/passwords#update"
    put "forgot", to: "devise/passwords#update"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "styleguide", to: "styleguide#index"

  root to: "top#index"
end
