# frozen_string_literal: true

require 'logger'
require './lib/database'

class Config
  def configure
    setup_i18n
    setup_database
    self
  end

  def token
    YAML.load_file('config/secrets.yml').fetch('telegram_bot_token')
  end

  def logger
    Logger.new($stdout, Logger::DEBUG)
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.locale = :en
    I18n.backend.load_translations
  end

  def setup_database
    Database.establish_connection
  end
end
