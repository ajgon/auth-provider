Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', sessions: 'sessions' }
  root 'home#index'

  get '/users/auth/:provider/setup' => 'sessions#setup'
end
