require_relative "lib/lockfile"

Gem::Specification.new do |gem|
  gem.name = "lockf.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/lockf.rb#readme"
  gem.version = Lock::File::VERSION
  gem.licenses = ["0BSD"]
  gem.files = Dir[
    "README.md", "LICENSE", 
    "Rakefile.rb", "lib/*.rb", 
    "lib/**/*.rb", "share/lockf.rb/examples/*.rb"
  ]
  gem.require_paths = ["lib"]
  gem.summary = "Ruby bindings for lockf(3)"
  gem.description = gem.summary

  gem.add_runtime_dependency "fiddle", "~> 1.1"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "standard", "~> 1.39"
  gem.add_development_dependency "rubocop", "~> 1.29"
  gem.add_development_dependency "test-unit", "~> 3.5"
  gem.add_development_dependency "test-cmd.rb", "~> 0.12"
end
