class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    # Projects already done: a maker has been accepted on them
    @completed_projects = Project
                            .joins(:maker_projects)
                            .where(maker_projects: { status: "accepted" })
                            .order(created_at: :desc)

    # Get the ids of all projects that a maker has already accepted
    accepted_project_ids = MakerProject.where(status: "accepted").pluck(:project_id)
    # Hide the accepted projects from the published list
    hidden_project_ids = accepted_project_ids
    # If a maker is signed in, also hide the projects he already matched or dismissed
    hidden_project_ids += current_user.maker_projects.pluck(:project_id) if user_signed_in?
    # Keep only the projects that are NOT hidden, newest first
    @projects = Project.where.not(id: hidden_project_ids.uniq).order(created_at: :desc)
  end
end
