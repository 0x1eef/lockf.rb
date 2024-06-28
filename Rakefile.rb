require "bundler/setup"

namespace :format do
  desc "Run rubocop"
  task :ruby do
    sh "bundle exec rubocop -A"
  end
end
task format: %w[format:ruby]

desc "Run tests"
task :test do
  sh "bin/test-runner"
end
task default: %w[test]
