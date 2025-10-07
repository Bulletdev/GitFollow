# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitFollow::Client do
  let(:token) { 'test_token_123' }
  let(:username) { 'testuser' }

  describe '#initialize' do
    it 'raises error when token is nil' do
      expect { described_class.new(token: nil) }.to raise_error(ArgumentError, 'GitHub token is required')
    end

    it 'raises error when token is empty' do
      expect { described_class.new(token: '') }.to raise_error(ArgumentError, 'GitHub token is required')
    end

    it 'initializes with valid token' do
      allow_any_instance_of(Octokit::Client).to receive(:user).and_return(double(login: username))

      client = described_class.new(token: token)

      expect(client).to be_a(described_class)
      expect(client.username).to eq(username)
    end

    it 'uses provided username if given' do
      client = described_class.new(token: token, username: username)

      expect(client.username).to eq(username)
    end
  end

  describe '#fetch_followers' do
    let(:client) { described_class.new(token: token, username: username) }

    it 'fetches followers successfully' do
      followers_data = [
        double(login: 'follower1', id: 1),
        double(login: 'follower2', id: 2)
      ]

      allow(client.client).to receive(:followers).with(username).and_return(followers_data)

      result = client.fetch_followers

      expect(result).to eq([
                             { login: 'follower1', id: 1 },
                             { login: 'follower2', id: 2 }
                           ])
    end

    it 'handles API errors' do
      allow(client.client).to receive(:followers).and_raise(Octokit::Unauthorized)

      expect { client.fetch_followers }.to raise_error(GitFollow::Error, /Authentication failed/)
    end
  end

  describe '#fetch_following' do
    let(:client) { described_class.new(token: token, username: username) }

    it 'fetches following successfully' do
      following_data = [
        double(login: 'following1', id: 1),
        double(login: 'following2', id: 2)
      ]

      allow(client.client).to receive(:following).with(username).and_return(following_data)

      result = client.fetch_following

      expect(result).to eq([
                             { login: 'following1', id: 1 },
                             { login: 'following2', id: 2 }
                           ])
    end
  end

  describe '#rate_limit' do
    let(:client) { described_class.new(token: token, username: username) }

    it 'returns rate limit information' do
      rate_limit_data = double(
        remaining: 4999,
        limit: 5000,
        resets_at: Time.now + 3600
      )

      allow(client.client).to receive(:rate_limit).and_return(rate_limit_data)

      result = client.rate_limit

      expect(result[:remaining]).to eq(4999)
      expect(result[:limit]).to eq(5000)
      expect(result[:resets_at]).to be_a(Time)
    end
  end

  describe '#create_issue' do
    let(:client) { described_class.new(token: token, username: username) }

    it 'creates an issue successfully' do
      issue_data = double(
        number: 123,
        html_url: 'https://github.com/user/repo/issues/123',
        title: 'Test Issue'
      )

      allow(client.client).to receive(:create_issue).and_return(issue_data)

      result = client.create_issue(
        repo: 'user/repo',
        title: 'Test Issue',
        body: 'Test body'
      )

      expect(result[:number]).to eq(123)
      expect(result[:url]).to eq('https://github.com/user/repo/issues/123')
      expect(result[:title]).to eq('Test Issue')
    end
  end

  describe '#valid_token?' do
    it 'returns true for valid token' do
      allow_any_instance_of(Octokit::Client).to receive(:user).and_return(double(login: username))

      client = described_class.new(token: token, username: username)

      expect(client.valid_token?).to be true
    end

    it 'returns false for invalid token' do
      allow_any_instance_of(Octokit::Client).to receive(:user).and_raise(Octokit::Unauthorized)

      client = described_class.new(token: token, username: username)

      expect(client.valid_token?).to be false
    end
  end
end
