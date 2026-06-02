class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # --- Mes Matchs ---
    # Projets du dreamer qui ont au moins un maker_project
    @maker_projects = MakerProject
                        .joins(:project)
                        .where(projects: { dreamer_id: current_user.id })
                        .includes(:project, :maker)
                        .order(updated_at: :desc)

    # On sépare "matchés" et "en attente" dans la vue
    # selon maker_project.status ("accepted" vs "pending")

    # --- Mes Projets (2 max pour l'aperçu) ---
    @projects = current_user.projects
                             .order(created_at: :desc)
                             .limit(2)

    # --- Mes Discussions ---
    # Les chats liés aux projets du dreamer
    @match_chats = MatchChat
                     .joins(maker_project: :project)
                     .where(projects: { dreamer_id: current_user.id })
                     .includes(:maker_project => [:maker, :project])
                     .order(updated_at: :desc)
  end
end
