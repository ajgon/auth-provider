Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  root 'home#index'

  get '/users/auth/:provider/setup' => 'sessions#setup'
end
