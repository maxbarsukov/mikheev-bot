# frozen_string_literal: true

require 'active_record'
require 'logger'

class Database
  class << self
    def establish_connection
      ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      configuration = YAML.safe_load(File.open(database_config_path))
      ActiveRecord::Base.establish_connection(configuration)
    end

    private

    def active_record_logger_path = 'log/bot.log'

    def database_config_path = 'config/database.yml'
  end
end
