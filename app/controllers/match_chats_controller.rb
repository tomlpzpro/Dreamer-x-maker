class MatchChatsController < ApplicationController
  def index
    if current_user.dreamer?
      # A dreamer sees the chats about the projects he created
      chats = MatchChat
                .joins(maker_project: :project)
                .where(projects: { dreamer_id: current_user.id })
                .includes(maker_project: [:maker, :project])
    else
      # A maker sees the chats about the projects he applied to
      chats = MatchChat
                .joins(:maker_project)
                .where(maker_projects: { maker_id: current_user.id })
                .includes(maker_project: { project: :dreamer })
    end
    # Unread discussions first, then the most recently active ones
    @match_chats = chats.ordered_for(current_user)
  end

  def show
    # Find the chat we want to display
    @match_chat = MatchChat.find(params[:id])
    # Opening the chat marks the messages from the other person as read
    @match_chat.match_messages.where.not(user: current_user).update_all(read: true)
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
      # The message itself is added live by the model broadcast.
      # Here we just reset the form (Turbo) or reload the page (no JS fallback).
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message_form",
            partial: "match_chats/form",
            locals: { match_chat: @match_chat, match_message: MatchMessage.new }
          )
        end
        format.html { redirect_to match_chat_path(@match_chat) }
      end
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
