class CreateLlmMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_messages do |t|
      t.string :content
      t.string :role
      t.references :llm_chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
