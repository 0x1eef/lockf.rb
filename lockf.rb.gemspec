require "./lib/lockf/version"
Gem::Specification.new do |gem|
  gem.name = "lockf.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/lockf.rb"
  gem.version = Lock::VERSION
  gem.licenses = ["MIT"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.extensions = %w[ext/lockf.rb/extconf.rb]
  gem.summary = "lockf.rb is a Ruby library that adds the POSIX function 'lockf'."
  gem.description = gem.summary
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "redcarpet", "~> 3.5"
  gem.add_development_dependency "rspec", "~> 3.10"
  gem.add_development_dependency "standard", "= 1.12.1"
  gem.add_development_dependency "rubocop", "= 1.29.1"
  gem.add_development_dependency "rake-compiler", "= 1.2.0"
end
