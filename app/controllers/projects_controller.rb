class ProjectsController < ApplicationController
  def index
    # Only the projects created by the logged-in dreamer
    @projects = current_user.projects.order(created_at: :desc)
  end

  def show
    @project = Project.find(params[:id])
    # The makers who applied to this project (with their status and their chat)
    @maker_projects = @project.maker_projects.includes(:maker, :match_chat)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.dreamer = current_user

    if params[:commit_action] == "generate"
      # "Générer mon visuel" button: save the project, then go to its AI chat
      # page so the user can generate a visual there.
      if @project.save
        chat = @project.llm_chats.create
        redirect_to ai_chat_path(chat), notice: "Projet créé ! Générez maintenant son visuel."
      else
        render :new, status: :unprocessable_entity
      end
    else
      # "Enregistrer le projet" button: only allowed if an image was uploaded.
      if @project.image.attached?
        @project.save
        redirect_to @project, notice: "Projet créé avec succès."
      else
        # No image and no generation: the form cannot be validated.
        @project.errors.add(:image, "Chargez une image ou cliquez sur « Générer mon visuel »")
        render :new, status: :unprocessable_entity
      end
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
    redirect_to projects_url, notice: "Project was successfully destroyed."
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :deadline, :budget, :image)
  end
end
