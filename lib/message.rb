# frozen_string_literal: true

require './lib/config'

class Message
  attr_reader :bot, :text, :chat, :reply_to_message_id, :logger

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @reply_to_message_id = options[:reply_to_message_id]

    @logger = Config.new.logger
  end

  def send
    bot.api.send_message(chat_id: chat.id, text:, reply_to_message_id:)
    logger.debug "sending '#{text}' to #{chat.username || chat.title}"
  end
end
