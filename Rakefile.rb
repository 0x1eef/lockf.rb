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
mv_proc = proc do
  mv File.join(__dir__, "lib", "lockf.rb.so"),
     File.join(__dir__, "lib", "lockf")
end
Rake::Task["compile"].enhance(&mv_proc)
Rake::Task["compile:lockf.rb"].enhance(&mv_proc)
task lint: ["linters:c", "linters:ruby"]
