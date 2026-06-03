class AiChatsController < ApplicationController
  def show
    # Find the chat we want to display
    @llm_chat = LlmChat.find(params[:id])
    # All the messages of this chat, oldest first
    @llm_messages = @llm_chat.llm_messages.order(:created_at)
    # Empty message used by the form at the bottom of the page
    @llm_message = LlmMessage.new
  end

  def create_message
    # Find the chat we are writing in
    @llm_chat = LlmChat.find(params[:id])
    # Build a new message for this chat
    @llm_message = @llm_chat.llm_messages.new(llm_message_params)
    # The user is the one writing this message
    @llm_message.role = "user"
    if @llm_message.save
      redirect_to ai_chat_path(@llm_chat)
    else
      # If saving fails, show the chat page again
      @llm_messages = @llm_chat.llm_messages.order(:created_at)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def llm_message_params
    params.require(:llm_message).permit(:content)
  end
end
