ConnectOp::Application.routes.draw do
  resource :session,   only: :destroy
  resource :dashboard, only: :show

  resources :clients, except: :show
  resources :authorizations, only: [:new, :create]
  resources :discovery, only: :show, intent: true

  namespace :connect do
    resource :fake,     only: :create
    resource :facebook, only: :show
    resource :google,   only: :show
    resource :client,   only: :create
  end

  root to: 'top#index'

  match '.well-known/:id', to: 'discovery#show'
  match 'user_info',       to: 'user_info#show', :via => [:get, :post]

  post 'access_tokens', to: proc { |env| TokenEndpoint.new.call(env) }
  get  'cert.pem',      to: proc { |env| [200, {}, [IdToken.config[:cert].to_pem]] }
  get  'cert.jwk',      to: proc { |env| [200, {}, [
    '{"keys":[{"alg":"EC","crv":"P-256","x":"MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4","y":"4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM","use":"enc","kid":"1"},{"alg":"RSA","mod":"0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw","exp":"AQAB","kid":"2011-04-29"}]}'
  ]] }
end
