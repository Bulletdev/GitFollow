# frozen_string_literal: true

require 'json'
require 'fileutils'

module GitFollow
  class Storage
    DEFAULT_DATA_DIR = File.join(Dir.home, '.gitfollow')
    SNAPSHOTS_FILE = 'snapshots.json'
    HISTORY_FILE = 'history.json'

    attr_reader :data_dir

    def initialize(data_dir: DEFAULT_DATA_DIR)
      @data_dir = data_dir
      ensure_data_dir_exists
    end

    def save_snapshot(username:, followers:, following:)
      snapshots = load_snapshots

      snapshot = {
        'username' => username,
        'timestamp' => Time.now.utc.iso8601,
        'followers' => deep_stringify(followers),
        'following' => deep_stringify(following),
        'stats' => {
          'followers_count' => followers.size,
          'following_count' => following.size,
          'mutual_count' => calculate_mutual(followers, following).size
        }
      }

      snapshots[username] ||= []
      snapshots[username] << snapshot

      write_json(snapshots_file_path, snapshots)
      snapshot
    end

    def latest_snapshot(username)
      snapshots = load_snapshots
      snapshots[username]&.last
    end

    def all_snapshots(username)
      snapshots = load_snapshots
      snapshots[username] || []
    end

    def save_history_entry(username:, event_type:, user_data:)
      history = load_history

      entry = {
        'username' => username,
        'event_type' => event_type.to_s,
        'user' => deep_stringify(user_data),
        'timestamp' => Time.now.utc.iso8601
      }

      history[username] ||= []
      history[username] << entry

      write_json(history_file_path, history)
      entry
    end

    def get_history(username, limit: nil)
      history = load_history
      entries = history[username] || []
      limit ? entries.last(limit) : entries
    end

    def clear_data(username)
      snapshots = load_snapshots
      history = load_history

      snapshots.delete(username)
      history.delete(username)

      write_json(snapshots_file_path, snapshots)
      write_json(history_file_path, history)
      true
    end

    def data_exists?(username)
      snapshots = load_snapshots
      !snapshots[username].nil? && !snapshots[username].empty?
    end

    def export(username:, format:, output_file:)
      case format
      when :json
        export_json(username, output_file)
      when :csv
        export_csv(username, output_file)
      else
        raise ArgumentError, "Unsupported export format: #{format}"
      end
    end

    private

    # Convert all symbol keys to strings recursively
    def deep_stringify(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(key, value), hash|
          hash[key.to_s] = deep_stringify(value)
        end
      when Array
        obj.map { |item| deep_stringify(item) }
      else
        obj
      end
    end

    def calculate_mutual(followers, following)
      follower_logins = followers.map { |f| f['login'] || f[:login] }
      following.select { |f| follower_logins.include?(f['login'] || f[:login]) }
    end

    def ensure_data_dir_exists
      FileUtils.mkdir_p(@data_dir)
    end

    def snapshots_file_path
      File.join(@data_dir, SNAPSHOTS_FILE)
    end

    def history_file_path
      File.join(@data_dir, HISTORY_FILE)
    end

    def load_snapshots
      load_json(snapshots_file_path)
    end

    def load_history
      load_json(history_file_path)
    end

    def load_json(file_path)
      return {} unless File.exist?(file_path)

      JSON.parse(File.read(file_path))
    rescue JSON::ParserError
      {}
    end

    def write_json(file_path, data)
      File.write(file_path, JSON.pretty_generate(data))
    end

    def export_json(username, output_file)
      data = {
        'username' => username,
        'snapshots' => all_snapshots(username),
        'history' => get_history(username)
      }
      write_json(output_file, data)
      output_file
    end

    def export_csv(username, output_file)
      require 'csv'

      history = get_history(username)

      CSV.open(output_file, 'w') do |csv|
        csv << ['Timestamp', 'Event Type', 'Username', 'User ID']

        history.each do |entry|
          csv << [
            entry['timestamp'],
            entry['event_type'],
            entry['user']['login'],
            entry['user']['id']
          ]
        end
      end

      output_file
    end
  end
end
