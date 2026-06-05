class LlmMessagesController < ApplicationController
  def create
    @llm_chat = LlmChat.find(params[:llm_chat_id])
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

  private

  def llm_message_params
    params.expect(llm_message: [:content])
  end
end
