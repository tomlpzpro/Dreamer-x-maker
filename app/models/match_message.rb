class MatchMessage < ApplicationRecord
  belongs_to :match_chat
  belongs_to :user
end
