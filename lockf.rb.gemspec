Gem::Specification.new do |gem|
  gem.name = "lockf.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/lockf.rb#readme"
  gem.version = "0.7.0"
  gem.licenses = ["0BSD"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.extensions = %w[ext/lockf.rb/extconf.rb]
  gem.summary = "A Ruby interface for lockf(3)"
  gem.description = gem.summary
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "redcarpet", "~> 3.5"
  gem.add_development_dependency "standard", "= 1.12.1"
  gem.add_development_dependency "rubocop", "= 1.29.1"
  gem.add_development_dependency "test-unit", "~> 3.5.7"
  gem.add_development_dependency "rake-compiler", "= 1.2.0"
end
