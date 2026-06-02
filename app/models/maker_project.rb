class MakerProject < ApplicationRecord
  belongs_to :project
  belongs_to :maker, class_name: "User"
  has_one :match_chat, dependent: :destroy
end
