class MatchChat < ApplicationRecord
  belongs_to :maker_project
  has_many :match_messages, dependent: :destroy

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
end
