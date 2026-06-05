class MatchMessage < ApplicationRecord
  belongs_to :match_chat
  belongs_to :user

  # Once a message is saved, push it in real time to the people concerned
  after_create_commit :broadcast_new_message

  private

  # Send the message to the open chat, and refresh the receiver's notif badge
  def broadcast_new_message
    # 1) Live chat: add the message at the bottom of the open discussion
    broadcast_append_to match_chat,
                        target: "#{ActionView::RecordIdentifier.dom_id(match_chat)}_messages",
                        partial: "match_messages/match_message",
                        locals: { message: self }

    # 2) Notification: refresh the badge of the person who receives the message
    receiver = match_chat.other_user(user)
    broadcast_replace_to receiver,
                         target: "notif_badge",
                         partial: "shared/notif_badge",
                         locals: { user: receiver }
  end
end
