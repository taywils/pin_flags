module PinFlags
  class Engine < ::Rails::Engine
    isolate_namespace PinFlags

    initializer "pin_flags.assets.precompile" do |app|
      app.config.assets.precompile += %w[pin_flags/application.css pin_flags/application.js]
    end
  end
end
