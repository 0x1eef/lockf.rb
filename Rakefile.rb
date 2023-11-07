require "rake/extensiontask"
require "rake/testtask"

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
  sh "mv",
     File.join(__dir__, "lib", "lockf.rb.so"),
     File.join(__dir__, "lib")
end
Rake::Task["compile"].enhance(&mv_proc)
Rake::Task["compile:lockf.rb"].enhance(&mv_proc)
task lint: ["linters:c", "linters:ruby"]

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = false
end
task default: %w[clobber compile test]
