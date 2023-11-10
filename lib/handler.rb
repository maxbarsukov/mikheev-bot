# frozen_string_literal: true

require 'English'
require 'json'

require './lib/message'
require './lib/utils/string_utils'
require './lib/utils/telegram_utils'
require './models/score'

class Handler
  using Utils::StringUtils
  attr_reader :message, :bot, :logger, :score

  def initialize(options)
    @logger = Config.new.logger

    @bot = options[:bot]
    @message = options[:message]

    user_id = message.from.id
    chat_id = message.chat.id
    username = Utils::TelegramUtils.creator_username(message)

    @score = Score.find_by(user_id:, chat_id:)
    @score = Score.create(user_id:, chat_id:, username:) if @score.nil?
    @score&.update(username:)
  end

  def chat_member_updated
    bot_name = Config.new.bot_name
    updates = bot.api.getUpdates

    logger.debug updates if updates[:ok] == false

    updates[:result]&.each do |result|
      logger.debug result

      added_username = result.dig(:my_chat_member, :new_chat_member, :user, :username)
      logger.debug "New user @#{added_username}"

      if added_username == bot_name
        reply_with_message('+- похуй')
        break
      end
    end
  end

  def respond
    pohui!
    return if message&.text.nil?

    count_plus_minus!

    begin
      on(%r{^/top}) { answer_top }
      on(%r{^/my_balance}) { answer_my_balance }
      on(%r{^/chat_balance}) { answer_chat_balance }
      on(%r{^/world_balance}) { answer_world_balance }
      on(%r{^/new_force}) { answer_new_force }
      on(%r{^/status}) { answer_status }
    rescue Telegram::Bot::Exceptions::ResponseError => e
      logger.error("Reponse Error: #{e}")
    end
  end

  private

  def pohui!
    return unless (message.from.username == 'NeoMent' && rand(1..50) == 2) || rand(1..500) == 2

    reply_with_message('похуй')
  end

  def dryad_message
    [
      'Пески времени текут. Честно говоря, вы стареете не очень изящно...',
      'Вы должны очистить этот мир от искажения',
      'Вы должны очистить этот мир от кримзона',
      'Сегодня дьявольская луна. Будьте осторожны',
      'Вы пробовали с помощью порошка очистить эбонит в искажении?',
      'Искажение попыталось поглотить меня, пока я направлялась в Этерию, но я смогла направить его силы против Армии Древних!'
    ].sample
  end

  def dryad_status(pluses_percent, chat_name)
    case pluses_percent
    when 100 then "#{chat_name} полностью очищен. Ты проделал прекрасную работу!"
    when 90...100 then 'Вы так близки!'
    when 80..90 then 'Мы живём как в сказке.'
    when 60..80 then 'Продолжай в том же духе!'
    when 40..60 then 'Мир находится в равновесии.'
    when 20..40 then 'Вам нужно лучше стараться.'
    when 10..20 then "У вас полно работы.\nВсё сейчас довольно мрачно."
    when 0..10 then 'Дела сильно испорчены...'
    else "#{chat_name} разрушен..."
    end
  end

  def answer_top
    top = Score.chat(message.chat.id)
               .where('plus_count > 0 OR minus_count > 0')
               .order(Arel.sql('(plus_count - minus_count) DESC'))
               .limit(10)

    text = "Топ #{top.count} математиков группы #{Utils::TelegramUtils.chat_name(message)}:\n"
    top.each_with_index do |sc, index|
      text << "#{index + 1}) #{sc.username}: баланс #{sc.balance} (#{sc.plus_count}+, #{sc.minus_count}-, #{sc.plus_minus_count}+-)\n"
    end

    reply_with_message(text)
  end

  def answer_my_balance
    text = "Баланс #{score.username}: #{score.balance}\n"
    text << "#{score.plus_count}+, #{score.minus_count}-, из них #{score.plus_minus_count}+-\n"
    all = score.plus_count + score.minus_count
    if all.zero?
      reply_with_message(text)
      return
    end

    text << "    Плюсов:  #{score.plus_percent}%\n"
    text << "    Минусов: #{score.minus_percent}%\n"
    text << if score.plus_count == score.minus_count
              "Баланс #{score.username} соблюден."
            else
              "Очев, #{score.plus_count > score.minus_count ? 'плюсов' : 'минусов'} больше"
            end

    text << "\n\n#{dryad_status(score.plus_percent, score.username)}\n"
    text << "    > #{dryad_message}" if rand(1..10) == 2
    reply_with_message(text)
  end

  def answer_chat_balance
    scores = Score.chat(message.chat.id).where('plus_count > 0 OR minus_count > 0')
    chat_name = Utils::TelegramUtils.chat_name(message)
    answer_group_balance(scores, "Мир '#{chat_name}'")
  end

  def answer_world_balance
    scores = Score.where('plus_count > 0 OR minus_count > 0')
    answer_group_balance(scores, 'Мир')
  end

  def answer_group_balance(scores, group_name)
    result = scores.with_plus_minus.first
    pluses = result.pluses
    minuses = result.minuses
    plus_minuses = result.plus_minuses

    text = "#{group_name}: баланс #{pluses - minuses}\n"
    text << "(#{pluses}+, #{minuses}-, из них #{plus_minuses}+-)\n"
    all = pluses + minuses
    if all.zero?
      reply_with_message(text)
      return
    end

    plus_percent = (pluses.to_f / all * 100).round(2)
    minus_percent = (minuses.to_f / all * 100).round(2)

    text << "    Плюсов:  #{plus_percent}%\n"
    text << "    Минусов: #{minus_percent}%\n"
    text << if pluses == minuses
              "#{group_name}: баланс соблюден."
            else
              "Очев, #{pluses > minuses ? 'плюсов' : 'минусов'} больше"
            end

    text << "\n\n#{dryad_status(plus_percent, group_name)}\n"
    text << "    > #{dryad_message}" if rand(1..10) == 2
    reply_with_message(text)
  end

  def count_plus_minus!
    pluses, minuses, plus_minuses = %w[+ - +-].map { |s| message.text.count_substring(s) }
    logger.debug "id#{message.chat.id}/#{message.message_id}: +(#{pluses}), -(#{minuses}), +-(#{plus_minuses})"
    return if [pluses, minuses, plus_minuses].sum.zero?

    score.update_counters(pluses, minuses, plus_minuses)
    logger.debug "#{score.username}'s score updated!"
  end

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

  def answer_with_message(text, reply_to_message_id = nil)
    Message.new(bot:, chat: message.chat, text:, reply_to_message_id:).send
  end

  def reply_with_message(text)
    answer_with_message(text, message.message_id)
  end
end
