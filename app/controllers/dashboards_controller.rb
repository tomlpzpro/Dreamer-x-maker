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

    # --- Mes Discussions ---
    @match_chats = MatchChat
                     .joins(maker_project: :project)
                     .where(projects: { dreamer_id: current_user.id })
                     .includes(maker_project: [:maker, :project])
                     .order(updated_at: :desc)
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

    # --- Mes Discussions ---
    @match_chats = MatchChat
                     .joins(:maker_project)
                     .where(maker_projects: { maker_id: current_user.id })
                     .includes(maker_project: { project: :dreamer })
                     .order(updated_at: :desc)
  end
