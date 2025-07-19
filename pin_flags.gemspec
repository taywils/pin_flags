require_relative "lib/pin_flags/version"

Gem::Specification.new do |spec|
  spec.name        = "pin_flags"
  spec.version     = PinFlags::VERSION
  spec.authors     = [ "Demetrious Wilson" ]
  spec.email       = [ "demetriouswilson@gmail.com" ]
  spec.homepage    = "https://github.com/taywils/pin_flags"
  spec.summary     = "⛳PinFlags is a granular, polymorphic feature access system"
  spec.description = "A lightweight Rails engine for managing entity-based feature flags with built-in caching support. Pin features to any ActiveRecord model with polymorphic associations, providing a flexible alternative to traditional feature flags. Includes a configurable cache expiry, and isolated namespace to avoid conflicts."
  spec.license     = "MIT"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 8.0", ">= 8.0.2"
  spec.add_dependency "turbo-rails", "~> 2.0"

  spec.add_development_dependency "debug", "~> 1.9"
  spec.add_development_dependency "rubocop-performance", "~> 1.21"
  spec.add_development_dependency "rubocop-rails-omakase", "~> 1.0"
  spec.add_development_dependency "propshaft", "~> 1.0"

  spec.required_ruby_version = ">= 3.0"
end
