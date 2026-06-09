class LlmChatsController < ApplicationController
  def generate_visual
    @llm_chat = LlmChat.find(params[:id])

    GenerateVisualJob.perform_later(@llm_chat)

    respond_to do |format|
      format.turbo_stream
    end
    # redirect_to @llm_chat.project, notice: "Visuel en cours de génération..."
  end

  private

  def llm_message_params
    params.require(:llm_message).permit(:content)
  end
end
