require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task :default => [:spec, :rubocop, :steep_check]

task :steep_check do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6.0')
    sh 'bundle exec steep check'
  end
end
