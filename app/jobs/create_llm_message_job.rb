class CreateLlmMessageJob < ApplicationJob
  queue_as :default

  def perform(chat, user_message)
    user_messages_count = chat.llm_messages.where(role: "user").count
    response_content = case user_messages_count
    when 1
      "Parfait, vous souhaitez créer #{user_message.content}. Pourriez-vous me préciser la matière souhaitée ainsi que la couleur ?"
    when 2
      "Merci ! Pourriez-vous me donner les dimensions souhaitées ? (Si vous les connaissez)"
    when 3
      "Ok, j'ai tout ce qu'il me faut ! Souhaitez-vous générer un visuel à partir de ces informations ?"
    else
      RubyLLM.chat.ask(user_message.content).content
    end

    llm_message = chat.llm_messages.create(role: "assistant", content: response_content)

    Turbo::StreamsChannel.broadcast_append_to(chat, target: "messages", partial: "llm_messages/llm_message", locals: { llm_message: llm_message })
  end
end
