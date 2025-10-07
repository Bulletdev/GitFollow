# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitFollow::Notifier do
  let(:username) { 'testuser' }
  let(:client) { instance_double(GitFollow::Client, username: username) }
  let(:notifier) { described_class.new(client: client) }

  let(:changes) do
    {
      new_followers: [{ login: 'newuser1', id: 1 }, { login: 'newuser2', id: 2 }],
      unfollowed: [{ login: 'olduser1', id: 3 }],
      has_changes: true,
      previous_count: 10,
      current_count: 11,
      net_change: 1
    }
  end

  let(:no_changes) do
    {
      new_followers: [],
      unfollowed: [],
      has_changes: false,
      previous_count: 10,
      current_count: 10,
      net_change: 0
    }
  end

  describe '#notify_via_issue' do
    it 'creates an issue with changes' do
      issue_data = {
        number: 123,
        url: 'https://github.com/user/repo/issues/123',
        title: 'Test Issue'
      }

      expect(client).to receive(:create_issue).and_return(issue_data)

      result = notifier.notify_via_issue(repo: 'user/repo', changes: changes)

      expect(result[:number]).to eq(123)
    end
  end

  describe '#format_terminal_output' do
    it 'formats changes with color' do
      output = notifier.format_terminal_output(changes, colorize: false)

      expect(output).to include('Changes detected')
      expect(output).to include('New Followers (2)')
      expect(output).to include('Unfollowed (1)')
      expect(output).to include('newuser1')
      expect(output).to include('olduser1')
    end

    it 'returns no changes message when no changes' do
      output = notifier.format_terminal_output(no_changes, colorize: false)

      expect(output).to include('No changes detected')
    end
  end

  describe '#format_as_table' do
    it 'formats changes as a table' do
      output = notifier.format_as_table(changes)

      expect(output).to include('New Followers')
      expect(output).to include('Unfollowed')
      expect(output).to include('newuser1')
      expect(output).to include('olduser1')
    end

    it 'returns no changes message when no changes' do
      output = notifier.format_as_table(no_changes)

      expect(output).to include('No changes detected')
    end
  end

  describe '#summary' do
    it 'generates summary with changes' do
      summary = notifier.summary(changes)

      expect(summary).to include('2 new follower(s)')
      expect(summary).to include('1 unfollow(s)')
      expect(summary).to include("@#{username}")
    end

    it 'returns no changes message when no changes' do
      summary = notifier.summary(no_changes)

      expect(summary).to include('No changes')
    end
  end
end
