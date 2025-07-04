module PinFlags
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "create_feature_tag.rb", "db/migrate/create_feature_tag.rb"
        migration_template "create_feature_subscriptions.rb", "db/migrate/create_feature_subscriptions.rb"
      end

      def copy_stimulus_controllers
        copy_file "stimulus/pin_flags_form_submit_controller.js", "app/javascript/controllers/pin_flags_form_submit_controller.js"
      end

      def self.next_migration_number(dirname)
        Time.current.utc.strftime("%Y%m%d%H%M%S")
      end
    end
  end
end
