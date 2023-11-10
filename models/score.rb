# frozen_string_literal: true

require 'active_record'
require './models/application_record'

class Score < ApplicationRecord
  scope :chat, ->(chat_id) { where(chat_id:) }
  scope :with_plus_minus, lambda {
    select('SUM(plus_count) as pluses, SUM(minus_count) as minuses, SUM(plus_minus_count) as plus_minuses')
  }

  validates :username, presence: true, length: { minimum: 1 }

  validates :plus_count,
            :minus_count,
            :plus_minus_count,
            presence: true, numericality: { only_integer: true }

  def balance
    plus_count - minus_count
  end

  def update_counters(pluses, minuses, plus_minuses)
    self.plus_count += pluses
    self.minus_count += minuses
    self.plus_minus_count += plus_minuses
    save!
  end

  def plus_percent
    all = plus_count + minus_count
    return 0 if all.zero?

    (plus_count.to_f / all).round(4) * 100
  end

  def minus_percent
    all = plus_count + minus_count
    return 0 if all.zero?

    (minus_count.to_f / all).round(4) * 100
  end
end
