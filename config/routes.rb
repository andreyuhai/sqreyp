Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :scrape_requests, only: [:new, :create]
  root 'scrape_requests#new'
end
