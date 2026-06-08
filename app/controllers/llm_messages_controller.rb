class LlmMessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Vous êtes un assistant IA pour la plateforme Dreamer x Maker.
    Vous suivez un script STRICT en 3 étapes. Ne déviez JAMAIS de ce script.

    ÉTAPE 1 — Répondez EXACTEMENT à ce format au premier message du Dreamer :
    "Parfait, vous souhaitez créer [objet mentionné par le Dreamer]. Pourriez-vous me préciser la matière souhaitée ainsi que la couleur ?"

    ÉTAPE 2 — Répondez EXACTEMENT à ce format au deuxième message du Dreamer :
    "Merci ! Pourriez-vous me donner les dimensions souhaitées ? (Si vous les connaissez)"

    ÉTAPE 3 — Répondez EXACTEMENT à ce format au troisième message du Dreamer :
    "Ok, j'ai tout ce qu'il me faut ! Souhaitez-vous générer un visuel à partir de ces informations ?"

    RÈGLES ABSOLUES :
    - Une seule question par réponse, jamais plus.
    - Ne demandez JAMAIS les dimensions à l'étape 1.
    - Ne demandez JAMAIS le style ou l'usage.
    - Maximum 200 caractères par réponse.
    - Répondez uniquement en français.
    - Ne générez PAS l'image.
  PROMPT

  def create
    @llm_chat = LlmChat.find(params[:llm_chat_id])
    @llm_message = @llm_chat.llm_messages.new(llm_message_params)
    @llm_message.role = "user"
    if @llm_message.save
      CreateLlmMessageJob.perform_later(@llm_chat, @llm_message)
      @llm_messages = @llm_chat.llm_messages.order(:created_at)
      respond_to do |format|
        # Turbo: the message is appended live by the model broadcast, so here
        # we only reset the form. No page reload, the scroll stays in place.
        format.turbo_stream
        # Fallback for non-Turbo clients: reload the project page as before.
        format.html { redirect_to @llm_chat.project }
      end
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
