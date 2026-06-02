class LlmChat < ApplicationRecord
  belongs_to :project
  has_many :llm_messages, dependent: :destroy
end
