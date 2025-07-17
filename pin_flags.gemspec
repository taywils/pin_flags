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

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir() do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
  spec.add_dependency "turbo-rails"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails-omakase"
  spec.add_development_dependency "propshaft"
end
