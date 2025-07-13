module PinFlags
  class Engine < ::Rails::Engine
    isolate_namespace PinFlags

    initializer "pin_flags.assets.precompile" do |app|
      app.config.assets.precompile += %w[
        pin_flags/alpine.min.js
        pin_flags/bulma.min.css
        pin_flags/application.css
      ]
    end
  end
end
