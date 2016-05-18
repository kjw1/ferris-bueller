require 'json'

require 'sinatra/base'

require_relative 'metadata'
require_relative 'replies'
require_relative 'web_helpers'

Thread.abort_on_exception = true


module FerrisBueller
  class Web < Sinatra::Application
    include WebHelpers
    include Replies

    get '/' do
      log.debug event: 'get /'
      content_type :text
      'Sup.'
    end


    get '/v' do
      log.debug event: 'get /v'
      content_type :text
      VERSION
    end


    get '/s' do
      log.debug event: 'get /s'
      content_type :json
      store.to_json
    end


    post '/' do
      log.debug event: 'post /', params: params
      unless params['token'] == settings.verification_token
        log.error event: 'verification failed', params: params
        halt 403
      else
        content_type :json
        reply, post = respond(params)
        settings.post_queue << post if post
        JSON.generate reply if reply
      end
    end



  private

    def respond params
      case params['text'].strip
      when 'whoami'
        reply_whoami params
      when /^help/
        reply_help params
      when ''
        reply_list params
      when 'list'
        reply_list params
      when 'summary'
        reply_summary params
      when /^(\d+)$/
        reply_show $1, params
      when /^show (\d+)/
        reply_show $1, params
      when /^resolve (\d+)/
        reply_resolve $1, params
      when /^close (\d+)/
        reply_close $1, params
      when /^open (\d+) (.*)/m
        reply_open $1, $2, params
      when /^comment (\d+) (.*)/m
        reply_comment $1, $2, params
      else
        reply_dunno params
      end
    end

  end
end
