class MatchChatsController < ApplicationController
  def show
    # Find the chat we want to display
    @match_chat = MatchChat.find(params[:id])
    # All the messages of this chat, oldest first
    @match_messages = @match_chat.match_messages.order(:created_at)
    # Empty message used by the form at the bottom of the page
    @match_message = MatchMessage.new
  end

  def create_message
    # Find the chat we are writing in
    @match_chat = MatchChat.find(params[:id])
    # Build a new message for this chat
    @match_message = @match_chat.match_messages.new(match_message_params)
    # The logged-in user is the one writing this message
    @match_message.user = current_user
    if @match_message.save
      redirect_to match_chat_path(@match_chat)
    else
      # If saving fails, show the chat page again
      @match_messages = @match_chat.match_messages.order(:created_at)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def match_message_params
    params.require(:match_message).permit(:content)
  end
end
