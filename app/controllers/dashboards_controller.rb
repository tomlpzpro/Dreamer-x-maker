class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # 1/ Conditions avec le role du user pour app bonnes methodes en private
    if current_user.role == "dreamer"
      get_dreamer_data
    else
      get_maker_data
    end

    #2/ Conditions d'affichage du dashboard en fonction du role du user
    if current_user.role == "dreamer"
      render "dashboards/dreamer"
    else
      render "dashboards/maker"
    end
  end
end

  private

  # DASHBOARD DREAMER
  def get_dreamer_data
    # --- Mes Matchs ---
    @maker_projects = MakerProject
                        .joins(:project)
                        .where(projects: { dreamer_id: current_user.id })
                        .includes(:project, :maker)
                        .order(updated_at: :desc)

    # --- Mes Projets (4 max pour l'aperçu du dashboard) ---
    @projects = current_user.projects
                             .order(created_at: :desc)
                             .limit(4)

    # --- Mes Discussions (non lues en premier, puis les plus récentes) ---
    @match_chats = MatchChat
                     .joins(maker_project: :project)
                     .where(projects: { dreamer_id: current_user.id })
                     .includes(maker_project: [:maker, :project])
                     .ordered_for(current_user)
  end

  # DASHBOARD MAKER
  def get_maker_data
    # --- Mes Matchs envoyés ---
    @maker_projects = current_user.maker_projects
                                   .includes(:project, :match_chat)
                                   .order(updated_at: :desc)

    # --- Mes projets en cours (les projets où ce maker a été accepté) ---
    @current_projects = Project
                          .joins(:maker_projects)
                          .where(maker_projects: { maker_id: current_user.id, status: "accepted" })
                          .order(created_at: :desc)
    # --- Projets disponibles (postés par les dreamers, pas encore acceptés) ---
    # Get the ids of all projects that a maker has already accepted
    accepted_project_ids = MakerProject.where(status: "accepted").pluck(:project_id)
    # Get the ids of the projects this maker already matched or dismissed
    my_project_ids = current_user.maker_projects.pluck(:project_id)
    # Hide both the accepted projects and the ones this maker already acted on
    hidden_project_ids = (accepted_project_ids + my_project_ids).uniq
    # Keep only the projects that are NOT hidden, newest first
    @open_projects = Project.where.not(id: hidden_project_ids).order(created_at: :desc)

    if params[:category].present?
      @open_projects = @open_projects.where(category: params[:category])
    end

    # --- Mes Discussions (non lues en premier, puis les plus récentes) ---
    @match_chats = MatchChat
                     .joins(:maker_project)
                     .where(maker_projects: { maker_id: current_user.id })
                     .includes(maker_project: { project: :dreamer })
                     .ordered_for(current_user)
  end
