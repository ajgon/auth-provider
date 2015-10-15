Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' } # , sessions: 'sessions' }
  root 'home#index'

  get '/users/auth/:provider/setup' => 'omniauth#setup'

  devise_scope :user do
    post '/login/usernamepassword' => 'login#index', as: 'login'
    post '/login/authorize' => 'login#authorize', as: 'login_authorize'
  end
end
