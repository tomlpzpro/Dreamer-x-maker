class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    # Get the ids of all projects that a maker has already accepted
    accepted_project_ids = MakerProject.where(status: "accepted").pluck(:project_id)
    # Keep only the projects that are NOT in that accepted list, newest first
    @projects = Project.where.not(id: accepted_project_ids).order(created_at: :desc)
  end
end
