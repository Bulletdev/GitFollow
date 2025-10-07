# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitFollow do
  it 'has a version number' do
    expect(GitFollow::VERSION).not_to be_nil
  end

  it 'defines the Client class' do
    expect(defined?(GitFollow::Client)).to eq('constant')
  end

  it 'defines the Storage class' do
    expect(defined?(GitFollow::Storage)).to eq('constant')
  end

  it 'defines the Tracker class' do
    expect(defined?(GitFollow::Tracker)).to eq('constant')
  end

  it 'defines the Notifier class' do
    expect(defined?(GitFollow::Notifier)).to eq('constant')
  end

  it 'defines the CLI class' do
    expect(defined?(GitFollow::CLI)).to eq('constant')
  end

  it 'defines the Error class' do
    expect(defined?(GitFollow::Error)).to eq('constant')
  end
end
