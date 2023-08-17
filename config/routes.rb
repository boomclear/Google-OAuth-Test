Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'welcome#index'

  resources :events, only: %i[new create index]

  get '/oauth', to: 'google#oauth'
  get '/calendars', to: 'google#calendars'
  get '/callback', to: 'google#callback'
  post '/create', to: "google#create"
end
