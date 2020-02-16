Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  resources :scrape_requests, only: [:new, :create]
  root 'scrape_requests#new'
end
