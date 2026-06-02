class CreateMatchChats < ActiveRecord::Migration[8.1]
  def change
    create_table :match_chats do |t|
      t.references :maker_project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
