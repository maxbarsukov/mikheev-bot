# frozen_string_literal: true

require 'telegram/bot'

require './lib/handler'
require './lib/config'

config = Config.new.configure
logger = config.logger

logger.debug 'Starting telegram bot'

Telegram::Bot::Client.run(config.token) do |bot|
  bot.listen do |message|
    options = { bot:, message: }
    logger.debug "@#{message.from?.username}: #{message.text}"
    Handler.new(options).respond
  end
end
