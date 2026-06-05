class LlmChatsController < ApplicationController
  def generate_visual
    @llm_chat = LlmChat.find(params[:id])
    image = RubyLLM.paint(@llm_chat.llm_messages.where(role: "assistant").last.content)
    @llm_chat.project.image.attach(
      io: StringIO.new(Base64.decode64(image.data)),
      filename: "generated_#{@llm_chat.project.id}.png",
      content_type: "image/png"
    )
    redirect_to @llm_chat.project, notice: "Visuel généré !"
  end

  private

  def llm_message_params
    params.require(:llm_message).permit(:content)
  end
end
