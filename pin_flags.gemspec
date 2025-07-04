require_relative "lib/pin_flags/version"

Gem::Specification.new do |spec|
  spec.name        = "pin_flags"
  spec.version     = PinFlags::VERSION
  spec.authors     = [ "Demetrious Wilson" ]
  spec.email       = [ "demetriouswilson@gmail.com" ]
  spec.homepage    = ""
  spec.summary     = "⛳PinFlags is a granular, polymorphic feature access system"
  spec.description = "TODO: Description of PinFlags."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."

  spec.files = Dir.chdir() do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"

  spec.add_development_dependency "debug", ">= 1.0.0"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails-omakase"
  spec.add_development_dependency "propshaft"
end
