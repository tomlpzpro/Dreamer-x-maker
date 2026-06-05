class CreateLlmMessageJob < ApplicationJob
  include ActionView::RecordIdentifier

  queue_as :default

  SYSTEM_PROMPT =
    <<~PROMPT
      Vous êtes un assistant IA spécialisé en design d'objets décoratifs et artisanaux.

      Aidez les Dreamers à décrire et affiner leur idée d'objet décoratif ou de mode pour qu'elle soit réalisable par un artisan.

      Posez des questions sur le style, les matériaux, les dimensions, les couleurs et l'usage de l'objet pour construire une description précise.

      Ne générez PAS l'image vous-même : décrivez seulement le visuel en texte. C'est le Dreamer qui choisira de générer le visuel grâce au bouton "Générer mon visuel".

      Répondez de manière concise et visuellement descriptive, en 300 caractères maximum.
    PROMPT

  def perform(user_message)
    # Do something later
    response = RubyLLM.chat.with_instructions(SYSTEM_PROMPT).ask(user_message.content)
    assistant_message = user_message.llm_chat.llm_messages.create(role: "assistant", content: response.content)

    broadcast_replace(assistant_message)
  end

  private

  def broadcast_replace(message)
    puts "*******************************"
    puts "*******************************"
    puts "*******************************"
    puts dom_id(message.llm_chat)
    puts "*******************************"
    puts "*******************************"
    Turbo::StreamsChannel.broadcast_append_to("IloybGtPaTh2WkhKbFlXMWxjaTE0TFcxaGEyVnlMMHhzYlVOb1lYUXZPUSI=--6461bb0eff628476a9581029978b3796171ea130d2d6c1499914faae69202fa3", target: dom_id(message.llm_chat), partial: "llm_messages/llm_message", locals: { message: message })
  end
end
