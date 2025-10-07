# frozen_string_literal: true

module GitFollow
  class Notifier
    attr_reader :client, :username

    def initialize(client:)
      @client = client
      @username = client.username
    end

    def notify_via_issue(repo:, changes:)
      title = generate_issue_title(changes)
      body = generate_issue_body(changes)

      @client.create_issue(repo: repo, title: title, body: body)
    end

    def format_terminal_output(changes, colorize: true)
      return "No changes detected for @#{@username}" unless changes[:has_changes]

      output = []

      if colorize
        require 'colorize'
        output << "Changes detected for @#{@username}".green.bold
      else
        output << "Changes detected for @#{@username}"
      end

      output << ''

      if changes[:new_followers].any?
        output << format_new_followers(changes[:new_followers], colorize)
        output << ''
      end

      if changes[:unfollowed].any?
        output << format_unfollowed(changes[:unfollowed], colorize)
        output << ''
      end

      output << "Net change: #{format_net_change(changes[:net_change], colorize)}"
      output << "Previous: #{changes[:previous_count]} → Current: #{changes[:current_count]}"

      output.join("\n")
    end

    def format_as_table(changes)
      require 'tty-table'

      return "No changes detected for @#{@username}" unless changes[:has_changes]

      output = []

      if changes[:new_followers].any?
        new_followers_table = TTY::Table.new(
          header: ['New Followers', 'GitHub ID'],
          rows: changes[:new_followers].map { |u| ["@#{u[:login]}", u[:id]] }
        )
        output << new_followers_table.render(:unicode, padding: [0, 1])
      end

      if changes[:unfollowed].any?
        unfollowed_table = TTY::Table.new(
          header: ['Unfollowed', 'GitHub ID'],
          rows: changes[:unfollowed].map { |u| ["@#{u[:login]}", u[:id]] }
        )
        output << unfollowed_table.render(:unicode, padding: [0, 1])
      end

      summary_table = TTY::Table.new(
        rows: [
          ['Previous Count', changes[:previous_count]],
          ['Current Count', changes[:current_count]],
          ['Net Change', format_net_change(changes[:net_change], false)]
        ]
      )
      output << summary_table.render(:unicode, padding: [0, 1])

      output.join("\n\n")
    end

    def summary(changes)
      return "No changes for @#{@username}" unless changes[:has_changes]

      parts = []

      parts << "#{changes[:new_followers].size} new follower(s)" if changes[:new_followers].any?
      parts << "#{changes[:unfollowed].size} unfollow(s)" if changes[:unfollowed].any?

      "#{parts.join(', ')} for @#{@username}"
    end

    private

    def generate_issue_title(changes)
      parts = []

      parts << "#{changes[:new_followers].size} new" if changes[:new_followers].any?
      parts << "#{changes[:unfollowed].size} unfollowed" if changes[:unfollowed].any?

      "GitFollow: #{parts.join(', ')} - #{Time.now.strftime('%Y-%m-%d')}"
    end

    def generate_issue_body(changes)
      body = []
      body << "# Follower Changes for @#{@username}"
      body << ''
      body << "**Date:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')}"
      body << ''

      if changes[:new_followers].any?
        body << "## ✅ New Followers (#{changes[:new_followers].size})"
        body << ''
        changes[:new_followers].each do |user|
          body << "- [@#{user[:login]}](https://github.com/#{user[:login]})"
        end
        body << ''
      end

      if changes[:unfollowed].any?
        body << "## ❌ Unfollowed (#{changes[:unfollowed].size})"
        body << ''
        changes[:unfollowed].each do |user|
          body << "- [@#{user[:login]}](https://github.com/#{user[:login]})"
        end
        body << ''
      end

      body << '## Summary'
      body << ''
      body << "- **Previous Count:** #{changes[:previous_count]}"
      body << "- **Current Count:** #{changes[:current_count]}"
      body << "- **Net Change:** #{format_net_change(changes[:net_change], false)}"
      body << ''
      body << '---'
      body << '_Automated notification from [GitFollow](https://github.com/bulletdev/gitfollow)_'

      body.join("\n")
    end

    def format_new_followers(new_followers, colorize)
      header = "✅ New Followers (#{new_followers.size}):"

      if colorize
        require 'colorize'
        header = header.green
      end

      lines = [header]
      new_followers.each do |user|
        lines << "  • @#{user[:login]}"
      end

      lines.join("\n")
    end

    def format_unfollowed(unfollowed, colorize)
      header = "❌ Unfollowed (#{unfollowed.size}):"

      if colorize
        require 'colorize'
        header = header.red
      end

      lines = [header]
      unfollowed.each do |user|
        lines << "  • @#{user[:login]}"
      end

      lines.join("\n")
    end

    def format_net_change(net_change, colorize)
      sign = net_change.positive? ? '+' : ''
      value = "#{sign}#{net_change}"

      return value unless colorize

      require 'colorize'
      if net_change.positive?
        value.green
      elsif net_change.negative?
        value.red
      else
        value
      end
    end
  end
end
