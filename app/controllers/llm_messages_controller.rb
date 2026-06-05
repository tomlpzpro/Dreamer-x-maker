class LlmMessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Vous êtes un assistant IA spécialisé en design d'objets décoratifs et artisanaux.

    Aidez les Dreamers à décrire et affiner leur idée d'objet décoratif ou de mode pour qu'elle soit réalisable par un artisan.

    Posez des questions sur le style, les matériaux, les dimensions, les couleurs et l'usage de l'objet pour construire une description précise.

    Ne générez PAS l'image vous-même : décrivez seulement le visuel en texte. C'est le Dreamer qui choisira de générer le visuel grâce au bouton "Générer mon visuel".

    Répondez de manière concise et visuellement descriptive, en 300 caractères maximum.
  PROMPT
  def create
    @llm_chat = LlmChat.find(params[:llm_chat_id])
    @llm_message = @llm_chat.llm_messages.new(llm_message_params)
    @llm_message.role = "user"
    if @llm_message.save
      response = RubyLLM.chat.with_instructions(SYSTEM_PROMPT).ask(@llm_message.content)
      @llm_chat.llm_messages.create(role: "assistant", content: response.content)
      redirect_to @llm_chat.project
    else
      @llm_messages = @llm_chat.llm_messages.order(:created_at)
      render "projects/show", status: :unprocessable_entity
    end
  end

  private

  def llm_message_params
    params.expect(llm_message: [:content])
  end
end
