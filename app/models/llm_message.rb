class LlmMessage < ApplicationRecord
  belongs_to :llm_chat

  # When a message is created (by the user or the AI job), push it live to
  # everyone watching this chat, appended inside the "messages" container.
end
