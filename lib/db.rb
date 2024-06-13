# frozen_string_literal: true

require 'activerecord'
require 'yaml'

module Obsidian
  class DB
    def self.setup
      db_config = YAML.load_file('config/database.yml')
      ActiveRecord::Base.establish_connection(db_config['development'])
      run_migrations
    end

    def self.run_migrations
      ActiveRecord::Migrator.migration_paths = ['db/migrate']
      migrations = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths,
                                                      ActiveRecord::SchemaMigration).migrations
      ActiveRecord::Migrator.new(:up, migrations).migrate
    end
  end
end
