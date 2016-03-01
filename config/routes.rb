# frozen_string_literal: true
Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' } # , sessions: 'sessions' }
  root 'home#index'

  get '/users/auth/:provider/setup' => 'omniauth#setup'

  devise_scope :user do
    get '/session' => 'session#index'
    post '/login/usernamepassword' => 'login#index', as: 'login'
    post '/login/authorize' => 'login#authorize', as: 'login_authorize'
    get '/login/:provider' => 'login#provider', as: 'login_provider'
  end

  namespace :api do
    namespace :v1 do
      get '/users/me' => 'users#me'
      post '/users/widget' => 'users#widget'
    end
  end

  post '/widget' => 'api/v1/users#widget'
  get '/userinfo' => 'api/v1/users#me'
end
