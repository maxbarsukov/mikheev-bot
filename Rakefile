# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'yaml'

require 'sqlite3'
require 'active_record'

namespace :db do
  connection_details = YAML.safe_load(File.open('config/database.yml'))

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::MigrationContext.new('db/migrate/', ActiveRecord::SchemaMigration).migrate

    Rake::Task['db:schema'].invoke
    ActiveRecord::Base.connection_handler.clear_all_connections!

    puts 'Database migrated.'
  end

  desc 'Rollback the last migration'
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Base.connection.migration_context.rollback(step)

    Rake::Task['db:schema'].invoke
    puts 'Database rollback.'
  end

  desc 'Create the database'
  task :create do
    ActiveRecord::Base.establish_connection(connection_details)
    SQLite3::Database.open(connection_details.fetch('database'))
    puts 'Database created.'
  end

  desc 'Drop the database'
  task :drop do
    ActiveRecord::Base.connection_handler.clear_all_connections!
    File.delete(connection_details.fetch('database'))

    puts 'Database deleted.'
  end

  desc 'Reset the database'
  task :reset => [:drop, :create, :migrate]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    require 'active_record/schema_dumper'
    filename = 'db/schema.rb'

    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::SchemaDumper.dump(connection, file)
      end
    end
    puts 'Schema generated.'
  end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")

    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
# frozen_string_literal: true

class #{migration_class} < ActiveRecord::Migration[7.1]
  def change
  end
end
      EOF
    end

    puts "Migration #{path} created."
    abort
  end
end
