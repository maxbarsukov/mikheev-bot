# frozen_string_literal: true

require 'logger'
require './lib/database'

class Config
  def configure
    setup_database
    self
  end

  def token
    YAML.load_file('config/secrets.yml').fetch('telegram_bot_token')
  end

  def bot_name
    YAML.load_file('config/secrets.yml').fetch('bot_name')
  end

  def logger
    Logger.new($stdout, Logger::DEBUG)
  end

  private

  def setup_database
    Database.establish_connection
  end
end
