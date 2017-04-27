class WeezEventApi
  attr_accessor :username, :password, :api_key, :we_uri, :access_token, :error, :default_params

  def initialize(*attributes)
    super
    @username     ||= ENV['WE_USERNAME']
    @password     ||= ENV['WE_PASSWORD']
    @api_key      ||= ENV['WE_API_KEY']
    @we_uri       ||= "https://api.weezevent.com"
    begin
      @access_token ||= get_access_token
    rescue RestClient::Forbidden
      @error = :forbidden
    end
    @default_params = { api_key: @api_key, access_token: @access_token }
  end

  def connected?
    self.access_token.present?
  end

  def update_events!(forced = false)
    weez_events = get '/events', {include_not_published: true, include_without_sales: true}
    if weez_events['events'].present? and weez_events['events'].any?
      weez_events['events'].each do |event|
        wid = event['id'].to_i
        we = WeezEvent.find_or_create_by(wid: wid)

        # Get event details
        if forced or not we.data.present?
          event_data = get "/event/#{wid}/details"
          we.data = event_data['events'] if event_data['events'].present?
          we.title = event['name']
          we.image = event_data['events']['image'] if event_data['events'].present?
          if we.data['period'].present?
            Time.zone = we.data['period']['timezone']
            we.date = Time.zone.parse(we.data['period']['start']) if defined? we.data['period']['start']
          end
          we.mini_site = we.data['extras']['minisite_url'] if we.data.present? and we.data['extras'].present?
          we.save!
        end

      end
    end
    weez_events['events'].present? ? weez_events['events'].size : false
  end

  private
    def get_access_token
      unless Thread.current[:we_access_token].present?
        params = {
          username: self.username,
          password: self.password,
          api_key: self.api_key
        }
        result = post '/auth/access_token', params, true
        Thread.current[:we_access_token] = result['accessToken']
      end
      Thread.current[:we_access_token]
    end

    def post url, params = {}, direct = false
      params = self.default_params.merge(params) unless direct
      url = self.we_uri + url
      response = RestClient.post url, params
      JSON.parse(response.body)
    end

    def get url, params = {}, direct = false
      params = self.default_params.merge(params) unless direct
      url = self.we_uri + url
      response = RestClient.get url, {params: params}
      JSON.parse(response.body)
    end
end