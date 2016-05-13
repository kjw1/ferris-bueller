require 'json'
require 'net/http'

require 'slog'

Thread.abort_on_exception = true


module FerrisBueller
  class SlackAPI
    def initialize options={}
      @token   = options.fetch :token
      @logger  = options.fetch :logger, Slog.new
      @api_url = options.fetch :api_url, 'https://slack.com/api'
      log.trace event: 'Slack API client initialized'
    end

    def send method, options={}
      uri = URI File.join(@api_url, method)
      options = { token: @token }.merge(options)
      log.trace event: 'sending api request', method: method, options: options
      res = Net::HTTP.post_form uri, options
      log.debug event: 'sent api request', method: method, options: options, response: res
      JSON.parse res.body, symbolize_names: true
    end

  private
    def log ; @logger end
  end
end