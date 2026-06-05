class MakerProject < ApplicationRecord
  belongs_to :project
  belongs_to :maker, class_name: "User"
  has_one :match_chat, dependent: :destroy

  # A maker can only have one link with a given project (so only one discussion
  # per project + maker + dreamer, since a project has a single dreamer).
  validates :maker_id, uniqueness: { scope: :project_id }

  # enum :status, { pending: "pending", validated: "validated", rejected: "rejected" }

end
