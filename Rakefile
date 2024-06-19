# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/string/inflections'
require 'rake'
require 'yaml'

namespace :db do
  task :load_config do
    env = ENV['APP_ENV'] || 'development'
    db_config = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(db_config[env])
  end

  desc 'Migrate the database'
  task migrate: :load_config do
    ActiveRecord::Migrator.migrations_paths = ['db/migrate']
    ActiveRecord::MigrationContext.new('db/migrate').migrate

    # Dump the schema to schema.rb
    File.open('db/schema.rb', 'w:utf-8') do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
    puts 'Updated db/schema.rb'
  end

  desc 'Create a new migration'
  task :create_migration, [:name] => :load_config do |_t, args|
    unless args[:name]
      raise "Migration name required. Usage: rake db:create_migration ['your_migration_name']"
    end

    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    migration_name = args[:name].underscore
    migration_file = "db/migrate/#{timestamp}_#{migration_name}.rb"
    migration_class = args[:name].camelize
    activerecord_version = ActiveRecord::VERSION::STRING

    migration_content = <<~MIGRATION
      class #{migration_class} < ActiveRecord::Migration[#{activerecord_version}]
        def change
        end
      end
    MIGRATION

    File.write(migration_file, migration_content)
    puts "Created migration #{migration_file}"
  end

  # not being used, but will keep for reference
  desc 'Seed the database'
  task seed: :load_config do
    load 'db/seeds.rb'
  end
end

