# frozen_string_literal: true

require 'active_record'
require './models/application_record'

class Score < ApplicationRecord
  scope :chat, ->(chat_id) { where(chat_id:) }

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
end
