class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @projects = Project.where.missing(:maker_projects)

    # Projects already done: a maker has been accepted on them
    @completed_projects = Project
                            .joins(:maker_projects)
                            .where(maker_projects: { status: "accepted" })
                            .order(created_at: :desc)
    # Get the ids of all projects that a maker has already accepted
    accepted_project_ids = MakerProject.where(status: "accepted").pluck(:project_id)
    # Keep only the projects that are NOT in that accepted list, newest first
    @projects = Project.where.not(id: accepted_project_ids).order(created_at: :desc)
  end
end
