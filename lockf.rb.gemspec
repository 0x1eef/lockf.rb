require "./lib/lockf/version"

Gem::Specification.new do |gem|
  gem.name = "lockf.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/lockf.rb#readme"
  gem.version = LockFile::VERSION
  gem.licenses = ["0BSD"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.extensions = %w[ext/lockf.rb/extconf.rb]
  gem.summary = "Ruby bindings for lockf(3)"
  gem.description = gem.summary
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "standard", "~> 1.12"
  gem.add_development_dependency "rubocop", "~> 1.29"
  gem.add_development_dependency "test-unit", "~> 3.5"
  gem.add_development_dependency "rake-compiler", "~> 1.2"
  gem.add_development_dependency "test-cmd.rb", "~> 0.12"
end
