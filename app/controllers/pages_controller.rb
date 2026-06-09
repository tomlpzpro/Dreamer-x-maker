class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home published_projects]

  def home
    # Projects already taken by a maker (accepted, made or delivered)
    @completed_projects = Project
                            .joins(:maker_projects)
                            .where(maker_projects: { status: MakerProject::ENGAGED_STATUSES })
                            .order(created_at: :desc)

    # Published projects
    @projects = Project.all
  end

  # Full page listing every published project
  def published_projects
    @categories = User::SKILLS
    @projects = Project.all.order(created_at: :desc)
    if params[:category].present?
      @projects = @projects.where(category: params[:category])
    end
  end

  # private

  # # Projects that are published and not yet taken by a maker, newest first
  # def open_projects
  #   # Get the ids of all projects that a maker has already accepted
  #   accepted_project_ids = MakerProject.where(status: "accepted").pluck(:project_id)
  #   # Hide the accepted projects from the published list
  #   hidden_project_ids = accepted_project_ids
  #   # If a maker is signed in, also hide the projects he already matched or dismissed
  #   hidden_project_ids += current_user.maker_projects.pluck(:project_id) if user_signed_in?
  #   # Keep only the projects that are NOT hidden, newest first
  #   Project.where.not(id: hidden_project_ids.uniq).order(created_at: :desc)
  # end
end
