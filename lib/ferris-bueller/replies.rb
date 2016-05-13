require_relative 'constants'
require_relative 'main'


module FerrisBueller
  module Replies
    include Constants

    def reply_whoami params
      u = user_lookup(params)
      if u
        { text: "You're <@#{params[:user_id]}>",
          attachments: [
            {
              title: 'Slack User',
              # pretext: 'User found via Slack APIs',
              text: "```#{JSON.pretty_generate(u[:slack])}```",
              mrkdwn_in: %w[ text pretext ]
            },
            {
              title: 'Jira User',
              # pretext: 'User found via Jira APIs',
              text: "```#{JSON.pretty_generate(u[:jira])}```",
              mrkdwn_in: %w[ text pretext ]
            }
          ]
        }
      else
        {
          text: "You're <@#{params[:user_id]}>, but I can't say much more than that"
        }
      end
    end


    def reply_help params
      { text: "Help!" }
    end


    def reply_dunno params
      { text: "Invalid usage. Try the `help` command" }
    end


    def reply_list params
      incidents = open_incidents
      return { text: 'Could not list incidents' } if incidents.nil?
      return { text: 'No open incidents at the moment' } if incidents.empty?

      attachments = incidents.map do |i|
        attach_incident(incident)
      end
      {
        text: 'Found %d open incidents' % attachments.size,
        attachments: attachments
      }
    end


    def reply_summary params
      incidents = recent_incidents
      return { text: 'Could not list incidents' } if incidents.nil?
      return { text: 'No recent incidents' } if incidents.empty?

      attachments = incidents.map do |i|
        attach_incident i
      end
      {
        text: 'Found %d recent incidents' % attachments.size,
        attachments: attachments
      }
    end


    def reply_show inc_num, params
      incident = select_incident inc_num
      return { text: 'Could not list incidents' } unless incident

      {
        attachments: [
          attach_incident(incident)
        ]
      }
    end


    def reply_resolve inc_num, params
      return { text: "You're not allowed to do that" } unless allowed? params

      incident = select_incident inc_num
      return { text: 'Could not list incidents' } unless incident

      resolution = resolve_incident incident
      return { text: 'Could not resolve incident' } if resolution.nil?
      return { text: 'Already resolved' } if resolution == false

      {
        text: 'Resolved incident',
        attachments: [
          attach_incident(incident)
        ]
      }
    end


    def reply_close inc_num, params
      return { text: "You're not allowed to do that" } unless allowed? params

      incident = select_incident inc_num
      return { text: 'Could not list incidents' } unless incident

      resolution = close_incident incident
      return { text: 'Could not close incident' } unless resolution

      {
        text: 'Closed incident',
        attachments: [
          attach_incident(incident)
        ]
      }
    end


    def reply_open sev_num, summary, params
      return { text: "You're not allowed to do that" } unless allowed? params

      new_incident = construct_incident sev_num, summary, params
      incident = open_incident new_incident, summary
      return { text: 'Could not open incident' } unless incident

      incident = new_incident.merge incident
      {
        text: 'Opened incident',
        attachments: [
          attach_incident(incident)
        ]
      }
    end


    def reply_comment inc_num, message, params
      incident = select_incident inc_num
      return { text: 'Could not list incidents' } unless incident

      comment = construct_comment message, params
      annotation = comment_on_incident incident, comment
      return { text: 'Could not comment on incident' } unless annotation

      {
        text: 'Commented on incident',
        attachments: [
          attach_incident(incident)
        ]
      }
    end



  private

    def attach_incident i
      {
        title: i[:key],
        text: i[:fields][:summary],
        mrkdwn_in: %w[ text pretext ]
      }
    end


    def resolve_incident i
      status = normalize_value i[:fields][:status]
      return false if status =~ RESOLVED_STATE

      log.trace \
        event: 'resolving incident',
        incident: i

      RESOLVED_TRANSITIONS.map do |tid|
        Thread.new do
          jira.send "/issue/#{i[:key]}/transitions?expand=transitions.fields", \
            transition: { id: tid }
        end
      end.join

      sleep 1.5 * settings.refresh_rate

      incident = select_incident i[:key].split('-',2).last
      status   = normalize_value incident[:fields][:status]

      log.debug \
        event: 'transitioned incident for resolve',
        incident: i,
        status: status

      return incident if status =~ RESOLVED_STATE
    end


    def close_incident i
      status = normalize_value i[:fields][:status]
      return false if status =~ CLOSED_STATE

      log.trace \
        event: 'closing incident',
        incident: i

      CLOSED_TRANSITIONS.map do |tid|
        Thread.new do
          jira.send "/issue/#{i[:key]}/transitions?expand=transitions.fields", \
            transition: { id: tid }
        end
      end.join

      sleep 1.5 * settings.refresh_rate

      incident = select_incident i[:key].split('-',2).last
      status   = normalize_value incident[:fields][:status]

      log.debug \
        event: 'transitioned incident for close',
        incident: i,
        status: status

      return incident if status =~ CLOSED_STATE
    end


    def construct_incident sev_num, summary, params
      u = user_lookup params
      return unless u
      {
        fields: {
          project: { key: settings.jira_project },
          issuetype: { name: settings.jira_type },
          reporter: { name: u[:jira][:nick] },
          summary: summary,
          SHOW_FIELDS.key('Severity') => {
            id: SEVERITIES[sev_num.to_i]
          }
        }
      }
    end


    def open_incident i, summary
      return unless i
      incident = jira.send 'issue', i
      return unless incident.include? :key
      log.info \
        event: 'opened incident',
        incident: incident
      incident
    end


    def construct_comment message, params
      u = user_lookup params
      return unless u
      {
        body: '_[~%s]_ says: %s' % [ u[:jira][:nick], message ]
      }
    end


    def comment_on_incident i, c
      return unless i
      return unless c
      resp = jira.send "/issue/#{i[:key]}/comment", c
      return unless resp.include? :id
      log.info \
        event: 'comment on incident',
        incident: i,
        comment: c
      resp
    end


    def recent_incidents
      return if store[:jira_incidents].nil?
      store[:jira_incidents].select do |i|
        Time.now - Time.parse(i[:fields][:created]) < one_day
      end
    end


    def open_incidents
      return if store[:jira_incidents].nil?
      store[:jira_incidents].select do |i|
        status = normalize_value i[:fields][:status]
        !(status =~ /resolved|closed/i)
      end
    end


    def select_incident num
      return if store[:jira_incidents].nil?
      store[:jira_incidents].select do |i|
        i[:key] =~ /-#{num}$/
      end.shift
    end


    def normalize_value val
      case val
      when Hash
        val[:name] || val[:value] || val
      when Array
        val.map { |v| v[:value] }.join(', ')
      when /^\d{4}\-\d{2}\-\d{2}/
        '%s (%s)' % [ val, normalize_date(val) ]
      else
        val
      end
    end


    def normalize_date val
      Time.parse(val).utc.iso8601(0).sub(/Z$/, 'UTC')
    end


    def friendly_date val
      Time.parse(val).strftime('%Y-%m-%d %H:%M %Z')
    end


    def one_day
      24 * 60 * 60 # seconds/day
    end

    def allowed? params
      u = user_lookup params
      u && store[:jira_members] \
        && store[:jira_members].include?(u[:jira][:nick])
    end


  end
end