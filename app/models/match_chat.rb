class MatchChat < ApplicationRecord
  belongs_to :maker_project
  has_many :match_messages, dependent: :destroy

  # Only one discussion per maker_project (i.e. per project + maker + dreamer)
  validates :maker_project_id, uniqueness: true

  # The maker who takes part in this chat
  def maker
    maker_project.maker
  end

  # The dreamer who takes part in this chat (the project owner)
  def dreamer
    maker_project.project.dreamer
  end

  # The other participant, seen from a given user's point of view
  def other_user(user)
    user == maker ? dreamer : maker
  end

  # Number of messages in this chat the given user has received and not read yet
  def unread_count_for(user)
    match_messages.count { |message| !message.read && message.user_id != user.id }
  end

  # Time of the last message (or the chat creation date if there is none yet)
  def last_message_at
    match_messages.map(&:created_at).max || created_at
  end

  # Order a list of chats for a user: the ones with unread messages first,
  # then the most recently active ones.
  def self.ordered_for(user)
    includes(:match_messages).sort_by do |chat|
      [chat.unread_count_for(user).zero? ? 1 : 0, -chat.last_message_at.to_f]
    end
  end
end
