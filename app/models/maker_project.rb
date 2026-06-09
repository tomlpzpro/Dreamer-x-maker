class MakerProject < ApplicationRecord
  belongs_to :project
  belongs_to :maker, class_name: "User"
  has_one :match_chat, dependent: :destroy

  # Photo of the finished project, uploaded by the dreamer when he receives it
  has_one_attached :delivery_photo

  # A maker can only have one link with a given project (so only one discussion
  # per project + maker + dreamer, since a project has a single dreamer).
  validates :maker_id, uniqueness: { scope: :project_id }

  # Rating (1 to 5) the dreamer gives to the maker when he receives the project
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  # The full life of an application, in order:
  # pending -> accepted -> made -> delivered  (or rejected at any point)
  #
  # Statuses where the maker is engaged on the project: the project is taken
  # and no longer open to other makers (accepted, then made, then delivered).
  ENGAGED_STATUSES = ["accepted", "made", "delivered"]
end
