# frozen_string_literal: true

require 'English'

require './models/score'
require './lib/message'

class Handler
  attr_reader :message, :bot, :score

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]

    @score = Score.find_or_create_by(user_id: message.from.id, chat_id: message.chat.id)
  end

  def respond
    on(%r{^/start}) do
      answer_with_greeting_message
    end

    on(%r{^/stop}) do
      answer_with_farewell_message
    end
  end

  private

  def on(regex, &block)
    regex =~ message.text

    return unless $LAST_MATCH_INFO

    case block.arity
    when 0
      yield
    when 1
      yield ::Regexp.last_match(1)
    when 2
      yield ::Regexp.last_match(1), ::Regexp.last_match(2)
    end
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    Message.new(bot:, chat: message.chat, text:).send
  end
end
