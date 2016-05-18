require 'json'
require 'net/http'

require 'slog'

Thread.abort_on_exception = true


module FerrisBueller
  class JiraAPI
    def initialize options={}
      @user      = options.fetch :user
      @pass      = options.fetch :pass
      @api_url   = options.fetch :api_url
      @base_path = options.fetch :base_path, '/rest/api/2'
      @logger    = options.fetch :logger, Slog.new
      log.debug event: 'Jira API client initialized'
    end

    def send path, data={}
      uri = URI File.join(@api_url, @base_path, path)
      http = Net::HTTP.new uri.hostname, uri.port
      http.use_ssl if uri.scheme == 'https'
      req = Net::HTTP::Post.new uri
      req.basic_auth @user, @pass
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'
      req.body = JSON.generate data
      log.debug \
        event: 'sending Jira API request',
        path: path,
        data: data
      raw_res = http.request(req).body
      begin
        return nil unless raw_res
        res = JSON.parse raw_res, symbolize_names: true
        log.debug \
          event: 'Jira API request returned',
          path: path,
          data: data,
          response: res
        res
      rescue => e
        log.error \
          event: 'exception parsing jira response',
          response: raw_res.inspect,
          exception: e.class,
          message: e.message.inspect,
          backtrace: e.backtrace
        raise e
      end
    end

  private
    def log ; @logger end
  end
end
