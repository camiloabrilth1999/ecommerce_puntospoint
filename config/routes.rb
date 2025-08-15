Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoints
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "health#show", as: :health_check

  # Sidekiq Web UI (only for development/admin access)
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  # API Routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post "auth/login", to: "auth#login"
      get "auth/validate", to: "auth#validate"
      delete "auth/logout", to: "auth#logout"

      # Analytics endpoints
      get "analytics/most_purchased_by_category", to: "analytics#most_purchased_by_category"
      get "analytics/top_revenue_by_category", to: "analytics#top_revenue_by_category"
      get "analytics/purchases", to: "analytics#purchases"
      get "analytics/purchases_by_granularity", to: "analytics#purchases_by_granularity"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
