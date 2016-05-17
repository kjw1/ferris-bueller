require_relative 'mjolnir'
require_relative 'metadata'
require_relative 'helpers'


module FerrisBueller
  class Main < Mjolnir
    include Helpers


    desc 'version', 'Show application version'
    def version
      puts VERSION
    end


    desc 'art', 'Show application art'
    def art
      puts "\n%s\n" % ART
    end


    desc 'start', 'Start Bender HipChat bot and Web server'
    option :api_token, \
      type: :string,
      aliases: %w[ -a ],
      desc: 'Set Slack API token',
      required: true,
      default: ENV['FERRIS_BUELLER_API_TOKEN']
    option :verification_token, \
      type: :string,
      aliases: %w[ -t ],
      desc: 'Set Slack verification token',
      required: true,
      default: ENV['FERRIS_BUELLER_VERIFICATION_TOKEN']
    option :database, \
      type: :string,
      aliases: %w[ -d ],
      desc: 'Set path to application database',
      required: true,
      default: ENV['FERRIS_BUELLER_DATABASE']
    option :jira_user, \
      type: :string,
      aliases: %w[ -u ],
      desc: 'Set JIRA username',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_USER']
    option :jira_pass, \
      type: :string,
      aliases: %w[ -p ],
      desc: 'Set JIRA password',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_PASS']
    option :jira_url, \
      type: :string,
      aliases: %w[ -j ],
      desc: 'Set JIRA base URL',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_URL']
    option :jira_project, \
      type: :string,
      aliases: %w[ -o ],
      desc: 'Set JIRA project',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_PROJECT']
    option :jira_group, \
      type: :string,
      aliases: %w[ -g ],
      desc: 'Set JIRA group for write mode',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_GROUP']
    option :jira_type, \
      type: :string,
      aliases: %w[ -e ],
      desc: 'Set JIRA issue type',
      required: true,
      default: ENV['FERRIS_BUELLER_JIRA_TYPE']
    option :user_refresh, \
      type: :numeric,
      aliases: %w[ -r ],
      desc: 'Set JIRA user refresh rate',
      default: (ENV['FERRIS_BUELLER_USER_REFRESH'] || 90)
    option :incident_refresh, \
      type: :numeric,
      aliases: %w[ -i ],
      desc: 'Set JIRA incident refresh rate',
      default: (ENV['FERRIS_BUELLER_INCIDENT_REFRESH'] || 2)
    option :member_refresh, \
      type: :numeric,
      aliases: %w[ -g ],
      desc: 'Set JIRA group membership refresh rate',
      default: (ENV['FERRIS_BUELLER_MEMBER_REFRESH'] || 60)
    option :environment, \
      type: :string,
      aliases: %w[ -m ],
      desc: 'Set environment for Web app',
      default: (ENV['FERRIS_BUELLER_ENVIRONMENT'] || 'development')
    option :port, \
      type: :numeric,
      aliases: %w[ -n ],
      desc: 'Set port for Web app',
      default: (ENV['FERRIS_BUELLER_PORT'] || 8080)
    option :bind, \
      type: :string,
      aliases: %w[ -b ],
      desc: 'Set bind for Web app',
      default: (ENV['FERRIS_BUELLER_BIND'] || '0.0.0.0')
    include_common_options
    def start
      log.info 'starting...'
      @store = {}
      go_refresh_jira_users
      go_refresh_jira_members
      go_refresh_jira_incidents
      start_your_day_off
    end

  end
end
