# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe GitFollow::Storage do
  let(:temp_dir) { Dir.mktmpdir }
  let(:storage) { described_class.new(data_dir: temp_dir) }
  let(:username) { 'testuser' }
  let(:followers) { [{ login: 'user1', id: 1 }, { login: 'user2', id: 2 }] }
  let(:following) { [{ login: 'user3', id: 3 }] }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#initialize' do
    it 'creates data directory if it does not exist' do
      expect(Dir.exist?(temp_dir)).to be true
    end
  end

  describe '#save_snapshot' do
    it 'saves a snapshot successfully' do
      snapshot = storage.save_snapshot(
        username: username,
        followers: followers,
        following: following
      )

      expect(snapshot['username']).to eq(username)
      expect(snapshot['followers'].size).to eq(2)
      expect(snapshot['followers'].first['login']).to eq('user1')
      expect(snapshot['following'].size).to eq(1)
      expect(snapshot['following'].first['login']).to eq('user3')
      expect(snapshot['stats']['followers_count']).to eq(2)
      expect(snapshot['stats']['following_count']).to eq(1)
      expect(snapshot['timestamp']).to be_a(String)
    end

    it 'appends snapshots for the same user' do
      storage.save_snapshot(username: username, followers: [], following: [])
      storage.save_snapshot(username: username, followers: followers, following: following)

      snapshots = storage.all_snapshots(username)

      expect(snapshots.size).to eq(2)
    end
  end

  describe '#latest_snapshot' do
    it 'returns the latest snapshot' do
      storage.save_snapshot(username: username, followers: [], following: [])
      storage.save_snapshot(username: username, followers: followers, following: following)

      latest = storage.latest_snapshot(username)

      expect(latest['followers'].size).to eq(2)
      expect(latest['followers'].first['login']).to eq('user1')
    end

    it 'returns nil if no snapshots exist' do
      expect(storage.latest_snapshot(username)).to be_nil
    end
  end

  describe '#all_snapshots' do
    it 'returns all snapshots for a user' do
      storage.save_snapshot(username: username, followers: [], following: [])
      storage.save_snapshot(username: username, followers: followers, following: following)

      snapshots = storage.all_snapshots(username)

      expect(snapshots.size).to eq(2)
    end

    it 'returns empty array if no snapshots exist' do
      expect(storage.all_snapshots(username)).to eq([])
    end
  end

  describe '#save_history_entry' do
    it 'saves a new follower entry' do
      entry = storage.save_history_entry(
        username: username,
        event_type: :new_follower,
        user_data: { login: 'newuser', id: 999 }
      )

      expect(entry['event_type']).to eq('new_follower')
      expect(entry['user']['login']).to eq('newuser')
      expect(entry['timestamp']).to be_a(String)
    end

    it 'saves an unfollow entry' do
      entry = storage.save_history_entry(
        username: username,
        event_type: :unfollowed,
        user_data: { login: 'olduser', id: 888 }
      )

      expect(entry['event_type']).to eq('unfollowed')
      expect(entry['user']['login']).to eq('olduser')
    end
  end

  describe '#get_history' do
    before do
      storage.save_history_entry(username: username, event_type: :new_follower, user_data: { login: 'user1', id: 1 })
      storage.save_history_entry(username: username, event_type: :unfollowed, user_data: { login: 'user2', id: 2 })
      storage.save_history_entry(username: username, event_type: :new_follower, user_data: { login: 'user3', id: 3 })
    end

    it 'returns all history entries' do
      history = storage.get_history(username)

      expect(history.size).to eq(3)
    end

    it 'returns limited history entries' do
      history = storage.get_history(username, limit: 2)

      expect(history.size).to eq(2)
      expect(history.last['user']['login']).to eq('user3')
    end

    it 'returns empty array for non-existent user' do
      expect(storage.get_history('nonexistent')).to eq([])
    end
  end

  describe '#data_exists?' do
    it 'returns true when data exists' do
      storage.save_snapshot(username: username, followers: followers, following: following)

      expect(storage.data_exists?(username)).to be true
    end

    it 'returns false when no data exists' do
      expect(storage.data_exists?(username)).to be false
    end
  end

  describe '#clear_data' do
    it 'clears all data for a user' do
      storage.save_snapshot(username: username, followers: followers, following: following)
      storage.save_history_entry(username: username, event_type: :new_follower, user_data: { login: 'user1', id: 1 })

      storage.clear_data(username)

      expect(storage.data_exists?(username)).to be false
      expect(storage.get_history(username)).to eq([])
    end
  end

  describe '#export' do
    before do
      storage.save_snapshot(username: username, followers: followers, following: following)
      storage.save_history_entry(username: username, event_type: :new_follower, user_data: { login: 'user1', id: 1 })
    end

    it 'exports to JSON format' do
      output_file = File.join(temp_dir, 'export.json')

      result = storage.export(username: username, format: :json, output_file: output_file)

      expect(result).to eq(output_file)
      expect(File.exist?(output_file)).to be true

      data = JSON.parse(File.read(output_file))
      expect(data['username']).to eq(username)
      expect(data['snapshots']).to be_an(Array)
      expect(data['history']).to be_an(Array)
    end

    it 'exports to CSV format' do
      output_file = File.join(temp_dir, 'export.csv')

      result = storage.export(username: username, format: :csv, output_file: output_file)

      expect(result).to eq(output_file)
      expect(File.exist?(output_file)).to be true
    end

    it 'raises error for unsupported format' do
      expect do
        storage.export(username: username, format: :xml, output_file: 'test.xml')
      end.to raise_error(ArgumentError, /Unsupported export format/)
    end
  end
end
