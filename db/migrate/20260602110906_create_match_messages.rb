class CreateMatchMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :match_messages do |t|
      t.string :content
      t.integer :user_id
      t.references :match_chat, null: false, foreign_key: true

      t.timestamps
    end
    add_foreign_key :match_messages, :users, column: :user_id
  end
end
