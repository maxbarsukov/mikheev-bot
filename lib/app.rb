# frozen_string_literal: true

require 'telegram/bot'

require './lib/handler'
require './lib/config'

config = Config.new.configure
logger = config.logger

logger.debug 'Starting telegram bot'

Telegram::Bot::Client.run(config.token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      options = { bot:, message: }
      logger.debug "@#{message.from&.username}: #{message&.text}"
      Handler.new(options).respond

    when Telegram::Bot::Types::ChatMemberUpdated
      options = { bot:, message: }
      logger.debug "! @#{message.from&.username}: chat member updated"
      Handler.new(options).chat_member_updated

    when Telegram::Bot::Types::PollAnswer
      logger.debug 'Poll answer'

    else
      logger.debug "Not sure what to do with this type of message by @#{message.from&.username}"
    end
  end
end
