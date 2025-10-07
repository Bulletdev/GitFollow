# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitFollow::Tracker do
  let(:token) { 'test_token' }
  let(:username) { 'testuser' }
  let(:client) { instance_double(GitFollow::Client, username: username) }
  let(:temp_dir) { Dir.mktmpdir }
  let(:storage) { GitFollow::Storage.new(data_dir: temp_dir) }
  let(:tracker) { described_class.new(client: client, storage: storage) }

  let(:followers) { [{ login: 'user1', id: 1 }, { login: 'user2', id: 2 }] }
  let(:following) { [{ login: 'user3', id: 3 }] }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#initial_setup' do
    it 'fetches and saves initial snapshot' do
      allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)

      snapshot = tracker.initial_setup

      expect(snapshot['username']).to eq(username)
      expect(snapshot['followers'].size).to eq(2)
      expect(snapshot['following'].size).to eq(1)
    end
  end

  describe '#check_changes' do
    context 'when no previous data exists' do
      it 'returns first_run message' do
        allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)

        result = tracker.check_changes

        expect(result[:first_run]).to be true
        expect(result[:message]).to include('No previous data')
      end
    end

    context 'when previous data exists' do
      before do
        allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)
        tracker.initial_setup
      end

      it 'detects no changes' do
        allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)

        result = tracker.check_changes

        expect(result[:has_changes]).to be false
        expect(result[:new_followers]).to be_empty
        expect(result[:unfollowed]).to be_empty
      end

      it 'detects new followers' do
        new_followers = followers + [{ login: 'newuser', id: 999 }]
        allow(client).to receive_messages(fetch_followers: new_followers, fetch_following: following)

        result = tracker.check_changes

        expect(result[:has_changes]).to be true
        expect(result[:new_followers].size).to eq(1)
        expect(result[:new_followers].first[:login]).to eq('newuser')
        expect(result[:net_change]).to eq(1)
      end

      it 'detects unfollows' do
        unfollowed = [followers.first]
        allow(client).to receive_messages(fetch_followers: unfollowed, fetch_following: following)

        result = tracker.check_changes

        expect(result[:has_changes]).to be true
        expect(result[:unfollowed].size).to eq(1)
        expect(result[:unfollowed].first['login']).to eq('user2')
        expect(result[:net_change]).to eq(-1)
      end
    end
  end

  describe '#statistics' do
    it 'returns nil when no data exists' do
      expect(tracker.statistics).to be_nil
    end

    it 'returns statistics when data exists' do
      allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)
      tracker.initial_setup

      stats = tracker.statistics

      expect(stats[:followers_count]).to eq(2)
      expect(stats[:following_count]).to eq(1)
      expect(stats[:mutual_count]).to eq(0)
      expect(stats[:ratio]).to eq(2.0)
      expect(stats[:total_new_followers]).to eq(0)
      expect(stats[:total_unfollows]).to eq(0)
    end
  end

  describe '#generate_report' do
    before do
      allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)
      tracker.initial_setup
    end

    it 'generates text report' do
      report = tracker.generate_report(format: :text)

      expect(report).to include('GitFollow Report')
      expect(report).to include(username)
      expect(report).to include('Followers:')
    end

    it 'generates markdown report' do
      report = tracker.generate_report(format: :markdown)

      expect(report).to include('# GitFollow Report')
      expect(report).to include("@#{username}")
      expect(report).to include('## Statistics')
    end

    it 'raises error for unsupported format' do
      expect do
        tracker.generate_report(format: :html)
      end.to raise_error(ArgumentError, /Unsupported format/)
    end
  end

  describe '#mutual_followers' do
    it 'returns empty array when no data exists' do
      expect(tracker.mutual_followers).to eq([])
    end

    it 'returns mutual followers' do
      mutual_user = { login: 'mutual', id: 100 }
      followers_with_mutual = followers + [mutual_user]
      following_with_mutual = following + [mutual_user]

      allow(client).to receive_messages(fetch_followers: followers_with_mutual, fetch_following: following_with_mutual)
      tracker.initial_setup

      mutual = tracker.mutual_followers

      expect(mutual.size).to eq(1)
      expect(mutual.first['login']).to eq('mutual')
    end
  end

  describe '#non_followers' do
    it 'returns empty array when no data exists' do
      expect(tracker.non_followers).to eq([])
    end

    it 'returns users who do not follow back' do
      allow(client).to receive_messages(fetch_followers: followers, fetch_following: following)
      tracker.initial_setup

      non_followers = tracker.non_followers

      expect(non_followers.size).to eq(1)
      expect(non_followers.first['login']).to eq('user3')
    end
  end
end
