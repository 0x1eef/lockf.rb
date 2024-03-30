require "bundler/setup"
require "rake/extensiontask"
require "rake/testtask"

namespace :clang do
  desc "Run clang-format"
  task :format do
    sh "clang-format -style=file:.clang-format -i ext/lockf.rb/*.c"
  end
end

namespace :ruby do
  desc "Run rubocop"
  task :format do
    sh "bundle exec rubocop -A"
  end
end
task format: %w[clang:format ruby:format]

Rake::ExtensionTask.new("lockf.rb")
Rake::TestTask.new do |t|
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
  t.warning = false
end
task default: %w[clobber compile test]
