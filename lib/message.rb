# frozen_string_literal: true

require './lib/config'

class Message
  attr_reader :bot, :text, :chat, :logger

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]

    @logger = Config.new.logger
  end

  def send
    bot.api.send_message(chat_id: chat.id, text:)
    logger.debug "sending '#{text}' to #{chat.username || chat.title}"
  end
end
