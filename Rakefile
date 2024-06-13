# frozen_string_literal: true

require 'active_record'
require 'yaml'

namespace :db do
  desc 'Establishes the database connection to ensure the database file exists'
  task :establish_connection do
    config = YAML.load_file('config/database.yml')['development']
    ActiveRecord::Base.establish_connection(config)
    puts "Database file ensured: #{config['database']}"
  end

  desc 'Migrate the database'
  task :migrate do
    config = YAML.load_file('config/database.yml')['development']
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Migrator.migrations_paths = ['db/migrate']
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
  end

  desc 'Create a new migration'
  task :create_migration, [:name] do |_t, args|
    unless args[:name]
      puts 'Usage: rake db:create_migration [create_notes]'
      exit 1
    end

    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    name = args[:name]
    filename = "db/migrate/#{timestamp}_#{name.underscore}.rb"
    migration_class_name = name.camelize

    File.write(filename, <<~FILE)
      class #{migration_class_name} < ActiveRecord::Migration[6.1]
        def change
        end
      end
    FILE
    puts "Created migration: #{filename}"
  end
end
