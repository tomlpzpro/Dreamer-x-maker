class MakerProjectsController < ApplicationController
  before_action :authenticate_user!

  # The maker matches a project: create the match and open the discussion
  def create
    # Find the project the maker wants to match with
    project = Project.find(params[:id])

    # Do nothing if this maker already has a link with this project
    if current_user.maker_projects.exists?(project: project)
      redirect_to project_path(project) and return
    end

    # Create the accepted match between this maker and the project
    maker_project = MakerProject.create!(project: project, maker: current_user, status: "accepted")
    # Open the discussion (chat) between the maker and the dreamer
    chat = MatchChat.create!(maker_project: maker_project)

    # Open the chat with the dreamer, with a confirmation message
    redirect_to match_chat_path(chat), notice: "C'est un match ! Vous pouvez maintenant discuter avec le dreamer."
  end

  # The maker says the project is not for him: hide it from his available projects
  def dismiss
    # Find the project the maker wants to hide
    project = Project.find(params[:id])

    # Keep a "rejected" link only if this maker has no link yet with this project
    unless current_user.maker_projects.exists?(project: project)
      MakerProject.create!(project: project, maker: current_user, status: "rejected")
    end

    # Go back to the page the maker came from (or the dashboard if unknown)
    redirect_to(params[:back].presence || dashboard_path, notice: "Projet retiré de vos projets disponibles.")
  end
end
