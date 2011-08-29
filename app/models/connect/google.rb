class Connect::Google < ActiveRecord::Base
  belongs_to :account

  validates :identifier,   presence: true, uniqueness: true
  validates :access_token, presence: true, uniqueness: true

  extend ActiveSupport::Memoizable

  def id_token
    hash = call_api self.class.config[:check_session_endpoint]
    # NOTE: Google returns different format of id_token response
    # OpenIDConnect::ResponseObject::IdToken.new hash
  end
  memoize :id_token

  def user_info
    hash = call_api self.class.config[:user_info_endpoint]
    OpenIDConnect::ResponseObject::UserInfo::OpenID.new hash
  end
  memoize :user_info

  private

  def to_bearer_token
    Rack::OAuth2::AccessToken::Bearer.new(
      access_token: access_token
    )
  end

  def call_api(endpoint)
    # NOTE:
    # Google doesn't support Authorization header, so I put access_token in query for now.
    endpoint = URI.parse endpoint
    endpoint.query = {access_token: access_token}.to_query
    res = to_bearer_token.get(endpoint)
    case res.status
    when 200
      JSON.parse(res.body).with_indifferent_access
    when 401
      raise Authentication::AuthenticationRequired.new('Access Token Invalid or Expired')
    else
      raise Rack::OAuth2::Client::Error.new('API Access Faild')
    end
  end

  class << self
    extend ActiveSupport::Memoizable

    def config
      config = YAML.load_file("#{Rails.root}/config/connect/google.yml")[Rails.env].symbolize_keys
      if Rails.env.production?
        config.merge!(
          client_id:     ENV['g_client_id'],
          client_secret: ENV['g_client_secret']
        )
      end
      config
    end
    memoize :config

    def client
      @client ||= Rack::OAuth2::Client.new(
        identifier:             config[:client_id],
        secret:                 config[:client_secret],
        authorization_endpoint: config[:authorization_endpoint],
        token_endpoint:         config[:token_endpoint],
        redirect_uri:           config[:redirect_uri]
      )
    end

    def authorization_uri
      client.authorization_uri(
        scope: config[:scope]
      )
    end

    def authenticate(code)
      client.authorization_code = code
      token = client.access_token!
      connect = find_or_initialize_by_identifier new(
        access_token: token.access_token
      ).id_token[:user_id]
      connect.access_token = token.access_token
      connect.save!
      connect.account || Account.create!(google: connect)
    end
  end
end