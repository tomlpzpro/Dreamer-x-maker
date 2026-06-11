class ProjectsController < ApplicationController
  # Only a dreamer can create or manage a project (a maker never owns one)
  before_action :require_dreamer, only: %i[new create edit update destroy]

  def index
    if current_user.role == "dreamer"
      @projects = current_user.projects.order(created_at: :desc)
    else
      # A maker only sees the projects he is engaged on (his real matches:
      # accepted, made or delivered), not the ones he dismissed with "Pas pour moi"
      @projects = current_user.matched_projects
                              .where(maker_projects: { status: MakerProject::ENGAGED_STATUSES })
                              .order(created_at: :desc)
    end
  end

  def show
    @project = Project.find(params[:id])
    # The makers who applied to this project (with their status and their chat)
    # NB: possibilité de ne plus voir les projets refusé, cf. code ci-dessous:
    # @maker_projects = @project.maker_projects..where.not(status: "rejected")includes(:maker, :match_chat)
    @maker_projects = @project.maker_projects.includes(:maker, :match_chat)
    # The AI chat only exists on projects created through the app (not seed ones)
    @llm_chat = @project.llm_chat
    # Load its messages only if the chat exists, otherwise keep an empty list
    @llm_messages = @llm_chat ? @llm_chat.llm_messages.order(:created_at) : []
    @llm_message = LlmMessage.new
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.dreamer = current_user

    if @project.save
      @chat = LlmChat.create(project: @project)
      @chat.llm_messages.create(
        role: "assistant",
        content: "Bonjour #{current_user.username}, je suis votre chatBot. Je vais vous aider, en vous guidant par étape, à concevoir et réaliser un visuel de votre idée. Commencez par me dire l'objet que vous souhaitez créer."
      )
      redirect_to @project, notice: "Projet créé ! Générez maintenant son visuel."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  # Block makers from the create/manage actions, server-side
  def require_dreamer
    return if current_user.dreamer?

    redirect_to projects_path, alert: "Seuls les dreamers peuvent créer ou gérer un projet."
  end

  def project_params
    params.require(:project).permit(:title, :description, :deadline, :budget, :image, :category)
  end

  # def validated_matched_projects
  #   current_user.matched_projects
  #               .where(maker_projects: { status: "validated" })
  #               .order(created_at: :desc)
  # end
end
