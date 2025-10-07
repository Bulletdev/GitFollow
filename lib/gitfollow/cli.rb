# frozen_string_literal: true

require 'thor'
require 'dotenv/load'
require 'tty-spinner'

module GitFollow
  class CLI < Thor
    class_option :token, type: :string, desc: 'GitHub personal access token (or set OCTOCAT_TOKEN env var)'
    class_option :data_dir, type: :string, desc: 'Directory to store data files'

    def self.exit_on_failure?
      true
    end

    desc 'init', 'Initialize GitFollow and create first snapshot'
    method_option :username, type: :string, desc: 'GitHub username (optional, will be fetched from token)'
    def init
      setup_components

      spinner = TTY::Spinner.new('[:spinner] Fetching initial data...', format: :dots)
      spinner.auto_spin

      begin
        snapshot = @tracker.initial_setup

        spinner.success('Done!')

        puts "\nInitialization complete!"
        puts "Username: @#{snapshot['username']}"
        puts "Followers: #{snapshot['stats']['followers_count']}"
        puts "Following: #{snapshot['stats']['following_count']}"
        puts "Mutual: #{snapshot['stats']['mutual_count']}"
        puts "\nRun 'gitfollow check' to detect changes."
      rescue StandardError => e
        spinner.error("Failed: #{e.message}")
        exit 1
      end
    end

    desc 'check', 'Check for follower changes'
    method_option :table, type: :boolean, default: false, desc: 'Display output as a table'
    method_option :json, type: :boolean, default: false, desc: 'Output changes in JSON format'
    method_option :notify, type: :string, desc: 'Create GitHub issue in repo (format: owner/repo)'
    method_option :quiet, type: :boolean, default: false, aliases: '-q', desc: 'Suppress output if no changes'
    def check
      setup_components

      spinner = TTY::Spinner.new('[:spinner] Checking for changes...', format: :dots)
      spinner.auto_spin

      begin
        changes = @tracker.check_changes

        spinner.success('Done!')

        if changes[:first_run]
          puts "\n#{changes[:message]}"
          puts 'Running initial setup...'
          invoke :init
          return
        end

        if changes[:has_changes]
          display_changes(changes)
          notify_if_requested(changes) if options[:notify]
        else
          puts "\nNo changes detected." unless options[:quiet]
        end
      rescue StandardError => e
        spinner.error("Failed: #{e.message}")
        exit 1
      end
    end

    desc 'report', 'Generate a detailed report'
    method_option :format, type: :string, default: 'text', enum: %w[text markdown], desc: 'Report format'
    method_option :output, type: :string, aliases: '-o', desc: 'Save report to file'
    def report
      setup_components

      begin
        report_content = @tracker.generate_report(format: options[:format].to_sym)

        if options[:output]
          File.write(options[:output], report_content)
          puts "Report saved to #{options[:output]}"
        else
          puts report_content
        end
      rescue StandardError => e
        puts "Error generating report: #{e.message}"
        exit 1
      end
    end

    desc 'stats', 'Display follower statistics'
    method_option :json, type: :boolean, default: false, desc: 'Output statistics in JSON format'
    def stats
      setup_components

      begin
        statistics = @tracker.statistics

        if statistics.nil?
          puts 'No data available. Run `gitfollow init` first.'
          exit 1
        end

        if options[:json]
          require 'json'
          puts JSON.pretty_generate(statistics)
        else
          display_statistics(statistics)
        end
      rescue StandardError => e
        puts "Error fetching statistics: #{e.message}"
        exit 1
      end
    end

    desc 'mutual', 'List mutual followers'
    method_option :json, type: :boolean, default: false, desc: 'Output in JSON format'
    def mutual
      setup_components

      begin
        mutual_followers = @tracker.mutual_followers

        if mutual_followers.empty?
          puts 'No mutual followers found.'
          return
        end

        if options[:json]
          require 'json'
          puts JSON.pretty_generate(mutual_followers)
        else
          puts "Mutual Followers (#{mutual_followers.size}):"
          mutual_followers.each do |user|
            puts "  • @#{user[:login]}"
          end
        end
      rescue StandardError => e
        puts "Error fetching mutual followers: #{e.message}"
        exit 1
      end
    end

    desc 'non-followers', 'List users you follow who don\'t follow back'
    method_option :json, type: :boolean, default: false, desc: 'Output in JSON format'
    def non_followers
      setup_components

      begin
        non_followers = @tracker.non_followers

        if non_followers.empty?
          puts 'All users you follow also follow you back!'
          return
        end

        if options[:json]
          require 'json'
          puts JSON.pretty_generate(non_followers)
        else
          puts "Non-Followers (#{non_followers.size}):"
          non_followers.each do |user|
            puts "  • @#{user[:login]}"
          end
        end
      rescue StandardError => e
        puts "Error fetching non-followers: #{e.message}"
        exit 1
      end
    end

    desc 'export FORMAT OUTPUT', 'Export data to file (formats: json, csv)'
    def export(format, output_file)
      setup_components

      begin
        format_sym = format.to_sym
        exported_file = @storage.export(
          username: @client.username,
          format: format_sym,
          output_file: output_file
        )

        puts "Data exported to #{exported_file}"
      rescue StandardError => e
        puts "Error exporting data: #{e.message}"
        exit 1
      end
    end

    desc 'clear', 'Clear all stored data'
    method_option :force, type: :boolean, default: false, aliases: '-f', desc: 'Skip confirmation'
    def clear
      setup_components

      unless options[:force]
        print "Are you sure you want to clear all data for @#{@client.username}? (y/N): "
        confirmation = $stdin.gets.chomp.downcase
        return unless confirmation == 'y'
      end

      begin
        @storage.clear_data(@client.username)
        puts "All data cleared for @#{@client.username}"
      rescue StandardError => e
        puts "Error clearing data: #{e.message}"
        exit 1
      end
    end

    desc 'version', 'Display GitFollow version'
    def version
      puts "GitFollow version #{GitFollow::VERSION}"
    end

    private

    def setup_components
      token = options[:token] || ENV.fetch('OCTOCAT_TOKEN', nil)

      if token.nil? || token.empty? || token.strip.empty?
        puts 'Error: GitHub token not provided or is empty.'
        puts 'Set OCTOCAT_TOKEN environment variable or use --token option.'
        puts 'Get a token at: https://github.com/settings/tokens'
        exit 1
      end

      begin
        @client = GitFollow::Client.new(token: token)

        unless @client.valid_token?
          puts 'Error: Invalid GitHub token or insufficient permissions.'
          puts 'Ensure your token has the following scopes: read:user, user:follow'
          puts 'Generate a new token at: https://github.com/settings/tokens'
          exit 1
        end

        data_dir = options[:data_dir] || GitFollow::Storage::DEFAULT_DATA_DIR
        @storage = GitFollow::Storage.new(data_dir: data_dir)
        @tracker = GitFollow::Tracker.new(client: @client, storage: @storage)
        @notifier = GitFollow::Notifier.new(client: @client)
      rescue GitFollow::Error => e
        puts "Error: #{e.message}"
        exit 1
      end
    end

    def display_changes(changes)
      if options[:json]
        require 'json'
        puts JSON.pretty_generate(changes)
      elsif options[:table]
        puts "\n#{@notifier.format_as_table(changes)}"
      else
        puts "\n#{@notifier.format_terminal_output(changes)}"
      end
    end

    # Display statistics in a formatted way
    def display_statistics(stats)
      require 'tty-table'

      puts "\nFollower Statistics for @#{@client.username}"
      puts '=' * 50

      stats_table = TTY::Table.new(
        rows: [
          ['Followers', stats[:followers_count]],
          ['Following', stats[:following_count]],
          ['Mutual', stats[:mutual_count]],
          ['Ratio', stats[:ratio]],
          ['Total New Followers', stats[:total_new_followers]],
          ['Total Unfollows', stats[:total_unfollows]]
        ]
      )
      puts stats_table.render(:unicode, padding: [0, 1])

      puts "\nLast Updated: #{Time.parse(stats[:last_updated]).strftime('%Y-%m-%d %H:%M:%S UTC')}"
    end

    def notify_if_requested(changes)
      return unless options[:notify]

      spinner = TTY::Spinner.new('[:spinner] Creating GitHub issue...', format: :dots)
      spinner.auto_spin

      begin
        issue = @notifier.notify_via_issue(repo: options[:notify], changes: changes)
        spinner.success("Issue created: #{issue[:url]}")
      rescue StandardError => e
        spinner.error("Failed to create issue: #{e.message}")
      end
    end
  end
end
