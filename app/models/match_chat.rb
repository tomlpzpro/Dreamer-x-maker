class MatchChat < ApplicationRecord
  belongs_to :maker_project
  has_many :match_messages, dependent: :destroy
end
