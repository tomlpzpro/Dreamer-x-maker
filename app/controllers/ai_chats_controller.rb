class AiChatsController < ApplicationController
  def show
    @llm_chat = LlmChat.find(params[:id])
    @llm_messages = @llm_chat.llm_messages.order(:created_at)
    @llm_message = LlmMessage.new
  end

  def create_message
    @llm_chat = LlmChat.find(params[:id])
    @llm_message = @llm_chat.llm_messages.new(llm_message_params)
    @llm_message.role = "user"
    if @llm_message.save
      response = RubyLLM.chat.ask(@llm_message.content)
      @llm_chat.llm_messages.create(role: "assistant", content: response.content)
      redirect_to @llm_chat.project
    else
      @llm_messages = @llm_chat.llm_messages.order(:created_at)
      render "projects/show", status: :unprocessable_entity
    end
  end

  def generer_visuel
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
