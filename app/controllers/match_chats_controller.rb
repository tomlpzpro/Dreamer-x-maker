class MatchChatsController < ApplicationController
  def index
    if current_user.dreamer?
      # A dreamer sees the chats about the projects he created
      @match_chats = MatchChat
                       .joins(maker_project: :project)
                       .where(projects: { dreamer_id: current_user.id })
                       .includes(maker_project: [:maker, :project])
                       .order(updated_at: :desc)
    else
      # A maker sees the chats about the projects he applied to
      @match_chats = MatchChat
                       .joins(:maker_project)
                       .where(maker_projects: { maker_id: current_user.id })
                       .includes(maker_project: { project: :dreamer })
                       .order(updated_at: :desc)
    end
  end

  def show
    # Find the chat we want to display
    @match_chat = MatchChat.find(params[:id])
    # All the messages of this chat, oldest first (with their author loaded)
    @match_messages = @match_chat.match_messages.includes(:user).order(:created_at)
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
      @match_messages = @match_chat.match_messages.includes(:user).order(:created_at)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def match_message_params
    params.require(:match_message).permit(:content)
  end
end
