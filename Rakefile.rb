require "bundler/setup"

namespace :format do
  desc "Apply rubocop fixes"
  task :apply do
    sh "bundle exec rubocop -A"
  end

  desc "Run rubocop"
  task :check do
    sh "bundle exec rubocop"
  end
end
task format: %w[format:apply]

desc "Run CI tasks"
task ci: %i[format:check test]

desc "Run tests"
task :test do
  sh <<-SHELL
    for t in test/test_*.rb; do 
      bundle exec ruby ${t} || exit 1
    done
  SHELL
end
task default: %w[test]
