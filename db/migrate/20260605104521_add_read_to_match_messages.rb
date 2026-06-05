class AddReadToMatchMessages < ActiveRecord::Migration[8.1]
  def change
    # New messages start as unread (false) so they can power the notification badge
    add_column :match_messages, :read, :boolean, default: false, null: false
  end
end
