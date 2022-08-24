require "rake/extensiontask"
require "bundler/gem_tasks"

namespace :linters do
  desc "Run the C linter"
  task :c do
    sh "uncrustify -c .uncrustify.cfg --no-backup --replace ext/lockf.rb/*.c"
  end

  desc "Run the Ruby linter"
  task :ruby do
    sh "bundle exec rubocop -A Rakefile.rb lib/**/*.rb spec/**/*.rb"
  end
end

Rake::ExtensionTask.new("lockf.rb")
Rake::Task["compile"].enhance do
  cp File.join(__dir__, "lib", "lockf.rb.so"),
     File.join(__dir__, "lib", "lockf")
end

task lint: ["linters:c", "linters:ruby"]
