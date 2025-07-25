module PinFlags
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        migration_template "create_feature_tag.rb", "db/migrate/create_feature_tag.rb"
        migration_template "create_feature_subscriptions.rb", "db/migrate/create_feature_subscriptions.rb"
      end

      def self.next_migration_number(dirname)
        # Increment by 1 second each time to ensure unique timestamps
        @migration_number ||= Time.current.utc.strftime("%Y%m%d%H%M%S").to_i
        @migration_number += 1
        @migration_number.to_s
      end
    end
  end
end
