# frozen_string_literal: true

class CreateScore < ActiveRecord::Migration[7.1]
  def change
    create_table :scores, primary_key: %i[user_id chat_id]  do |t|
      t.integer :user_id
      t.integer :chat_id

      t.string :username, null: false

      t.bigint :plus_count, null: false, default: 0
      t.bigint :minus_count, null: false, default: 0
      t.bigint :plus_minus_count, null: false, default: 0

      t.timestamps
    end

    add_index :scores, [:user_id, :chat_id], unique: true
    add_index :scores, :chat_id
  end
end
