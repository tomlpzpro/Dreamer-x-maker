class ProjectsController < ApplicationController
  def index
    # Only the projects created by the logged-in dreamer
    @projects = current_user.projects.order(created_at: :desc)
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.dreamer = current_user
    if @project.save
      redirect_to root_path, notice: "Project was successfully created."
      # le redirect_to root_path sera à modifier lorsque la route du dreamer_dashboard sera créée
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
    redirect_to projects_url, notice: "Project was successfully destroyed."
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :deadline, :budget, :image)
  end
end
