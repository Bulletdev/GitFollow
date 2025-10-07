# frozen_string_literal: true

require 'octokit'

module GitFollow
  class Client
    attr_reader :username, :client

    def initialize(token:, username: nil)
      raise ArgumentError, 'GitHub token is required' if token.nil? || token.empty?

      @client = Octokit::Client.new(access_token: token)
      @client.auto_paginate = true
      @username = username || fetch_username
    end

    def fetch_followers
      followers = @client.followers(@username)
      followers.map { |f| { login: f.login, id: f.id } }
    rescue Octokit::Error => e
      handle_error(e, 'fetching followers')
    end

    def fetch_following
      following = @client.following(@username)
      following.map { |f| { login: f.login, id: f.id } }
    rescue Octokit::Error => e
      handle_error(e, 'fetching following')
    end

    def rate_limit
      limit = @client.rate_limit
      {
        remaining: limit.remaining,
        limit: limit.limit,
        resets_at: limit.resets_at
      }
    rescue Octokit::Error => e
      handle_error(e, 'fetching rate limit')
    end

    def create_issue(repo:, title:, body:)
      issue = @client.create_issue(repo, title, body)
      {
        number: issue.number,
        url: issue.html_url,
        title: issue.title
      }
    rescue Octokit::Error => e
      handle_error(e, 'creating issue')
    end

    def valid_token?
      @client.user
      true
    rescue Octokit::Unauthorized
      false
    end

    private

    def fetch_username
      user = @client.user
      user.login
    rescue Octokit::Error => e
      handle_error(e, 'fetching username')
    end

    def handle_error(error, action)
      case error
      when Octokit::Unauthorized
        raise GitFollow::Error, "Authentication failed while #{action}. Please check your GitHub token."
      when Octokit::NotFound
        raise GitFollow::Error, "Resource not found while #{action}. Please check your username or repository."
      when Octokit::TooManyRequests
        reset_time = error.response_headers['X-RateLimit-Reset'].to_i
        reset_at = Time.at(reset_time)
        raise GitFollow::Error, "Rate limit exceeded while #{action}. Resets at #{reset_at}."
      when Octokit::ServerError
        raise GitFollow::Error, "GitHub server error while #{action}. Please try again later."
      else
        raise GitFollow::Error, "Error while #{action}: #{error.message}"
      end
    end
  end

  class Error < StandardError; end
end
