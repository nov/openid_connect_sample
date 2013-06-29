ConnectOp::Application.routes.draw do
  resource :session,   only: :destroy
  resource :dashboard, only: :show

  resources :clients, except: :show
  resources :authorizations, only: [:new, :create]

  namespace :connect do
    resource :fake,     only: :create
    resource :facebook, only: :show
    resource :google,   only: :show
    resource :client,   only: :create
  end

  root to: 'top#index'

  match '.well-known/:id', to: 'discovery#show'
  match 'user_info',        to: 'user_info#show', :via => [:get, :post]

  post 'access_tokens', to: proc { |env| TokenEndpoint.new.call(env) }
  get  'jwks.json',     to: proc { |env| [200, {'Content-Type' => 'application/json'}, [IdToken.config[:jwk_set].to_json]] }
end
