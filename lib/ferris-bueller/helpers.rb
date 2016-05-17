require 'json'
require 'net/http'

require 'thin/logging'
require 'queryparams'

require_relative 'constants'
require_relative 'web'
require_relative 'jira_api'
require_relative 'slack_api'


module FerrisBueller
  module Helpers
    include Constants


    def store ; @store end


    def start_your_day_off
      Web.set :environment, options.environment
      Web.set :port, options.port
      Web.set :bind, options.bind
      Web.set :store, @store
      Web.set :logger, log
      Web.set :verification_token, options.verification_token
      Web.set :api, SlackAPI.new(token: options.api_token, logger: log)
      Web.set :jira, JiraAPI.new(
        api_url: options.jira_url,
        user: options.jira_user,
        pass: options.jira_pass,
        logger: log
      )
      Web.set :jira_project, options.jira_project
      Web.set :jira_type, options.jira_type
      Web.set :refresh_rate, options.incident_refresh

      if log.level >= ::Logger::DEBUG
        Web.set :raise_errors, true
        Web.set :dump_errors, true
        Web.set :show_exceptions, true
        Web.set :logging, ::Logger::DEBUG
      end

      Thin::Logging.logger = log

      Web.run!
    end


    def go_refresh_jira_users
      Thread.new do
        loop do
          refresh_jira_users
          sleep options.user_refresh
        end
      end
    end


    def go_refresh_jira_members
      Thread.new do
        loop do
          refresh_jira_members
          sleep options.member_refresh
        end
      end
    end


    def go_refresh_jira_incidents
      Thread.new do
        loop do
          refresh_jira_incidents
          sleep options.incident_refresh
        end
      end
    end


    def refresh_jira_users
      data = jira_request 'user/assignable/search', \
        project: options.jira_project,
        startAt: 0,
        maxResults: 1_000_000

      users = data.inject({}) do |h, user|
        h[user[:name]] = {
          key: user[:key],
          nick: user[:name],
          name: user[:displayName],
          email: user[:emailAddress]
        } ; h
      end

      store[:jira_users] = users

    rescue StandardError => e
      log.error \
        error: 'could not refresh users',
        event: 'exception',
        class: e.class,
        message: e.message.inspect,
        backtrace: e.backtrace,
        remediation: 'pausing breifly before retrying'
      sleep RETRY_DELAY
      retry
    end


    def refresh_jira_members
      data = jira_request 'group', \
        groupname: options.jira_group,
        expand: 'users'

      user_names = data[:users][:items].map { |u| u[:name] }
      store[:jira_members] = user_names
    rescue StandardError => e
      log.error \
        error: 'could not refresh members',
        event: 'exception',
        class: e.class,
        message: e.message.inspect,
        backtrace: e.backtrace,
        remediation: 'pausing breifly before retrying'
      sleep RETRY_DELAY
      retry
    end


    def refresh_jira_incidents
      data = jira_request 'search', \
        jql: "project = #{options.jira_project} ORDER BY created ASC, priority DESC",
        fields: SHOW_FIELDS.keys.join(','),
        startAt: 0,
        maxResults: 1_000_000

      store[:jira_incidents] = data[:issues].map do |i|
        i[:num] = i[:key].split('-', 2).last ; i
      end
    rescue StandardError => e
      log.error \
        error: 'could not refresh incidents',
        event: 'exception',
        class: e.class,
        message: e.message.inspect,
        backtrace: e.backtrace,
        remediation: 'pausing breifly before retrying'
      sleep RETRY_DELAY
      retry
    end


    def jira_request path, params
      api_url = File.join options.jira_url, 'rest/api/latest', path
      log.debug \
        event: 'jira request',
        path: path,
        params: params,
        api_url: api_url
      encoded_params = QueryParams.encode params
      uri = URI(api_url + '?' + encoded_params)
      http = Net::HTTP.new uri.host, uri.port
      req = Net::HTTP::Get.new uri
      req.use_ssl if uri.scheme == 'https'
      req.basic_auth options.jira_user, options.jira_pass
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'
      resp = http.request req
      log.debug \
        event: 'jira request responded',
        path: path,
        params: params,
        api_url: api_url,
        response: resp
      JSON.parse resp.body, symbolize_names: true
    end

  end
end
