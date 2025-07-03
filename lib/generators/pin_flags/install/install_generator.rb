module PinFlags
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "create_feature_tag.rb", "db/migrate/create_feature_tag.rb"
        migration_template "create_feature_subscriptions.rb", "db/migrate/create_feature_subscriptions.rb"
      end
    end
  end
end
