Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/auth/login", to: "authentication#login"


  post "/clock_in", to: "sleep_record#clock_in"
  patch "/clock_out", to: "sleep_record#clock_out"
  get "/sleep_records", to: "sleep_record#index"

  get "/user/profile", to: "users#user_profile"
  get "/user/all", to: "users#all_user"
  post "/user/follow", to: "users#follow"
  delete "/user/unfollow", to: "users#unfollow"
end
