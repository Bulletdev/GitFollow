# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Run tests and linting'
task default: %i[spec rubocop]

desc 'Run tests with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Build and install gem locally'
task :install_local do
  sh 'gem build gitfollow.gemspec'
  sh 'gem install ./gitfollow-*.gem'
end

desc 'Clean generated files'
task :clean do
  sh 'rm -f *.gem'
  sh 'rm -rf coverage'
  sh 'rm -rf doc'
end
