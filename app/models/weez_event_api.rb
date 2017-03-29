class WeezEventApi
  attr_accessor :username, :password, :api_key, :we_uri, :access_token, :error

  def initialize(*attributes)
    super
    @username     ||= ENV['WE_USERNAME']
    @assword      ||= ENV['WE_PASSWORD']
    @api_key      ||= ENV['WE_API_KEY']
    @we_uri       ||= "https://api.weezevent.com"
    begin
      @access_token ||= get_access_token
    rescue RestClient::Forbidden
      @error = :forbidden
    end
  end

  def connected?
    self.access_token.present?
  end

  private
    def get_access_token
      params = {
        username: self.username,
        password: self.password,
        api_key: self.api_key
      }
      result = post '/auth/access_token', params
      result['accessToken']
    end

    def post url, params
      response = RestClient.post self.we_uri + url, params.to_json, content_type: "application/json; charset=utf-8"
      JSON.parse(response.body)
    end
end