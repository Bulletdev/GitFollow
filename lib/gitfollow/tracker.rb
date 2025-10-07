# frozen_string_literal: true

module GitFollow
  class Tracker
    attr_reader :client, :storage, :username

    def initialize(client:, storage:)
      @client = client
      @storage = storage
      @username = client.username
    end

    def initial_setup
      followers = @client.fetch_followers
      following = @client.fetch_following

      @storage.save_snapshot(
        username: @username,
        followers: followers,
        following: following
      )
    end

    def check_changes
      current_followers = @client.fetch_followers
      current_following = @client.fetch_following

      previous_snapshot = @storage.latest_snapshot(@username)

      if previous_snapshot.nil?
        return {
          first_run: true,
          message: 'No previous data found. Initializing...'
        }
      end

      changes = detect_changes(previous_snapshot, current_followers, current_following)

      # Save new snapshot
      @storage.save_snapshot(
        username: @username,
        followers: current_followers,
        following: current_following
      )

      save_history_entries(changes)

      changes
    end

    def statistics
      latest = @storage.latest_snapshot(@username)

      return nil if latest.nil?

      followers = latest['followers']
      following = latest['following']
      mutual = calculate_mutual(followers, following)

      history = @storage.get_history(@username)
      new_followers_count = history.count { |e| e['event_type'] == 'new_follower' }
      unfollows_count = history.count { |e| e['event_type'] == 'unfollowed' }

      {
        followers_count: followers.size,
        following_count: following.size,
        mutual_count: mutual.size,
        ratio: calculate_ratio(followers.size, following.size),
        total_new_followers: new_followers_count,
        total_unfollows: unfollows_count,
        last_updated: latest['timestamp']
      }
    end

    def generate_report(format: :text)
      stats = statistics

      return 'No data available. Run `gitfollow check` first.' if stats.nil?

      history = @storage.get_history(@username, limit: 20)

      case format
      when :markdown
        generate_markdown_report(stats, history)
      when :text
        generate_text_report(stats, history)
      else
        raise ArgumentError, "Unsupported format: #{format}"
      end
    end

    def mutual_followers
      latest = @storage.latest_snapshot(@username)
      return [] if latest.nil?

      calculate_mutual(latest['followers'], latest['following'])
    end

    def non_followers
      latest = @storage.latest_snapshot(@username)
      return [] if latest.nil?

      following = latest['following']
      follower_logins = latest['followers'].map { |f| f['login'] || f[:login] }

      following.reject { |f| follower_logins.include?(f['login'] || f[:login]) }
    end

    private

    def detect_changes(previous_snapshot, current_followers, _current_following)
      previous_followers = previous_snapshot['followers']

      # Extract IDs, handling both symbol and string keys
      previous_follower_ids = previous_followers.map { |f| f['id'] || f[:id] }
      current_follower_ids = current_followers.map { |f| f['id'] || f[:id] }

      new_follower_ids = current_follower_ids - previous_follower_ids
      unfollowed_ids = previous_follower_ids - current_follower_ids

      # Find users by ID, handling both symbol and string keys
      new_followers = current_followers.select { |f| new_follower_ids.include?(f['id'] || f[:id]) }
      unfollowed = previous_followers.select { |f| unfollowed_ids.include?(f['id'] || f[:id]) }

      {
        new_followers: new_followers,
        unfollowed: unfollowed,
        has_changes: !new_followers.empty? || !unfollowed.empty?,
        previous_count: previous_followers.size,
        current_count: current_followers.size,
        net_change: current_followers.size - previous_followers.size
      }
    end

    def save_history_entries(changes)
      changes[:new_followers].each do |user|
        @storage.save_history_entry(
          username: @username,
          event_type: :new_follower,
          user_data: user
        )
      end

      changes[:unfollowed].each do |user|
        @storage.save_history_entry(
          username: @username,
          event_type: :unfollowed,
          user_data: user
        )
      end
    end

    def calculate_mutual(followers, following)
      follower_logins = followers.map { |f| f['login'] || f[:login] }
      following.select { |f| follower_logins.include?(f['login'] || f[:login]) }
    end

    def calculate_ratio(followers_count, following_count)
      return 0.0 if following_count.zero?

      (followers_count.to_f / following_count).round(2)
    end

    def generate_markdown_report(stats, history)
      report = []
      report << "# GitFollow Report for @#{@username}"
      report << ''
      report << "**Last Updated:** #{Time.parse(stats[:last_updated]).strftime('%Y-%m-%d %H:%M:%S UTC')}"
      report << ''
      report << '## Statistics'
      report << ''
      report << "- **Followers:** #{stats[:followers_count]}"
      report << "- **Following:** #{stats[:following_count]}"
      report << "- **Mutual:** #{stats[:mutual_count]}"
      report << "- **Ratio:** #{stats[:ratio]}"
      report << "- **Total New Followers:** #{stats[:total_new_followers]}"
      report << "- **Total Unfollows:** #{stats[:total_unfollows]}"
      report << ''
      report << '## Recent Activity'
      report << ''

      if history.empty?
        report << '_No recent activity_'
      else
        report << '| Timestamp | Event | User |'
        report << '|-----------|-------|------|'

        history.reverse.each do |entry|
          timestamp = Time.parse(entry['timestamp']).strftime('%Y-%m-%d %H:%M')
          event = entry['event_type'] == 'new_follower' ? '✅ New Follower' : '❌ Unfollowed'
          user = "@#{entry['user']['login']}"

          report << "| #{timestamp} | #{event} | #{user} |"
        end
      end

      report << ''
      report << '---'
      report << '_Generated with [GitFollow](https://github.com/bulletdev/gitfollow)_'

      report.join("\n")
    end

    def generate_text_report(stats, history)
      report = []
      report << "GitFollow Report for @#{@username}"
      report << ('=' * 50)
      report << ''
      report << "Last Updated: #{Time.parse(stats[:last_updated]).strftime('%Y-%m-%d %H:%M:%S UTC')}"
      report << ''
      report << 'Statistics:'
      report << "  Followers:         #{stats[:followers_count]}"
      report << "  Following:         #{stats[:following_count]}"
      report << "  Mutual:            #{stats[:mutual_count]}"
      report << "  Ratio:             #{stats[:ratio]}"
      report << "  Total New:         #{stats[:total_new_followers]}"
      report << "  Total Unfollows:   #{stats[:total_unfollows]}"
      report << ''
      report << 'Recent Activity:'
      report << ('-' * 50)

      if history.empty?
        report << '  No recent activity'
      else
        history.reverse.each do |entry|
          timestamp = Time.parse(entry['timestamp']).strftime('%Y-%m-%d %H:%M')
          event = entry['event_type'] == 'new_follower' ? '✅ NEW' : '❌ UNFOLLOW'
          user = "@#{entry['user']['login']}"

          report << "  [#{timestamp}] #{event} #{user}"
        end
      end

      report.join("\n")
    end
  end
end
