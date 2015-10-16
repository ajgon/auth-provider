Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' } # , sessions: 'sessions' }
  root 'home#index'

  get '/users/auth/:provider/setup' => 'omniauth#setup'

  devise_scope :user do
    post '/login/usernamepassword' => 'login#index', as: 'login'
    post '/login/authorize' => 'login#authorize', as: 'login_authorize'
  end

  namespace :api do
    namespace :v1 do
      get '/users/me' => 'users#me'
    end
  end

  get '/userinfo' => 'api/v1/users#me'
end
