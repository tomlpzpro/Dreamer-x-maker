class Project < ApplicationRecord
  belongs_to :dreamer, class_name: "User"
  has_many :llm_chats, dependent: :destroy
  has_many :maker_projects, dependent: :destroy
  has_one_attached :image
end
