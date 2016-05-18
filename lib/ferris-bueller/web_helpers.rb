require 'fuzzystringmatch/pure/jarowinkler'


module FerrisBueller
  module WebHelpers
    JARO_WINKLER = FuzzyStringMatch::JaroWinklerPure.new

    def jira ; settings.jira end

    def store ; settings.store end

    def log ; settings.logger end

    def api ; settings.api end


    def user_lookup params, threshold=0.75
      data = api.send 'users.info', user: params[:user_id]

      slack_user = {
        key: data[:user][:id],
        name: (data[:user][:real_name] || data[:user][:name]),
        nick: data[:user][:name],
        email: data[:user][:email]
      }

      log.info \
        event: 'matching user',
        slack_user: slack_user

      jira_matches = store[:jira_users].values.map do |jira_user|
        distances = [ :name, :nick ].map do |k|
          compare slack_user[k], jira_user[k]
        end.compact
        mean_distance = 1.0 * distances.inject(:+) / distances.size
        if mean_distance > threshold or distances.max > 0.99
          { user: jira_user, distance: mean_distance}
        end
      end.compact

      jira_match = jira_matches.sort_by { |m| m[:distance] }.last

      unless jira_match
        log.warn \
          event: 'unmatched user',
          slack_user: slack_user
        return nil
      end

      log.info \
        event: 'matched user',
        slack_user: slack_user,
        jira_match: jira_match

      return { slack: slack_user, jira: jira_match[:user] }

    rescue StandardError => e
      log.error \
        error: 'could not lookup users',
        event: 'exception',
        exception: e.inspect,
        class: e.class,
        message: e.message.inspect,
        backtrace: e.backtrace
      return nil
    end


    def compare name1, name2
      return nil if name1.nil? || name1.empty?
      return nil if name2.nil? || name2.empty?
      n1 = name1.gsub(/\W/, '').downcase
      n2 = name2.gsub(/\W/, '').downcase
      JARO_WINKLER.getDistance n1, n2
    end

  end
end
