class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # 1/ Conditions avec le role du user pour app bonnes methodes en private
    # if current_user.role == "maker"
    #   get_maker_data()
    # else
    #   get_dreamer_data()
    # end

    #2/ Conditions d'affichage du dashboard en fonction du role du user
    # if current_user.role == "maker"
    #   render: "dashboards/maker.html.erb"
    # else
    #   render: "dashboards/dreamer.html.erb"
    # end

  end

  private

    # DASHBOARD DREAMER
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
                     
    # DASHBOARD MAKER

end
