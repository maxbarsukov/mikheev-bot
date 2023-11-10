# frozen_string_literal: true

module Utils
  module TelegramUtils
    module_function

    def creator_username(message)
      ("@#{message.from&.username}" if message.from&.username) || message.from&.first_name
    end

    def chat_name(message)
      message.chat.title || message.chat.username
    end
  end
end
