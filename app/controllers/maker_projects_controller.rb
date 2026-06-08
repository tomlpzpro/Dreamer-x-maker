class MakerProjectsController < ApplicationController
  before_action :authenticate_user!

  # The maker matches a project: create the match and open the discussion
  def create
    # Find the project the maker wants to match with
    project = Project.find(params[:id])

    # Only one discussion is allowed per project + maker + dreamer.
    # If this maker already has a link with this project, reuse it: open the
    # existing discussion if there is one, otherwise go back to the project.
    existing = current_user.maker_projects.find_by(project: project)
    if existing
      if existing.match_chat
        redirect_to match_chat_path(existing.match_chat) and return
      else
        redirect_to project_path(project) and return
      end
    end

    # Create the accepted match between this maker and the project
    maker_project = MakerProject.create!(project: project, maker: current_user, status: "pending")
    # Open the discussion (chat) between the maker and the dreamer
    chat = MatchChat.create!(maker_project: maker_project)

    # Open the chat with the dreamer, with a confirmation message
    redirect_to match_chat_path(chat), notice: "C'est un match ! Vous pouvez maintenant discuter avec le dreamer."
  end

  # dreamer valide une demande de participation d'un maker
  # => update makerProject -> status = "accepted"
  def approve
    # On cherche le projet grâce à l'id dans l'URL
    project = Project.find(params[:id])

    # On cherche la candidature (MakerProject) en attente sur ce projet
    # params[:maker_project_id] viendra du formulaire dans la vue
    maker_project = MakerProject.find(params[:maker_project_id])
    # un message auto généré dans le chat, envoyé par le dreamer au maker :
    match_chat = maker_project.match_chat
    MatchMessage.create(
      content: "Bonjour, Votre demande été acceptée ! Nous pouvons échanger plus en détail sur les détails de ce projet.",
      match_chat: match_chat,
      user: current_user
    )

    maker_projects = project.maker_projects.where.not(id: maker_project.id)
    maker_projects.each do |mp|
      # mp représente un maker_project que je souhaite refuser
      mp.update!(status: "rejected")
      MatchMessage.create(
        content: "Bonjour, Malheureusement votre demande sur ce projet n'a pas été acceptée, mais peut-être pour une prochaine fois !",
        match_chat: mp.match_chat,
        user: current_user
      )
    end

    # On change le statut de "pending" à "accepted"
    maker_project.update!(status: "accepted")

    # On redirige vers la page du projet avec un message de succès
    redirect_to project_path(project), notice: "Maker accepté !"
  end

  # dreamer refuse une demande de participation d'un maker
  # => update makerProject -> status = "rejected"
  #
  def dismiss
    # On cherche le projet via l'id dans l'URL
    project = Project.find(params[:id])

    # On crée une demande de match (candidature) "rejected"
    # seulement si ce maker n'en a pas encore
    unless current_user.maker_projects.exists?(project: project)
      MakerProject.create!(project: project, maker: current_user, status: "rejected")
    end

    # On retourne là d'où venait le maker (ou le dashboard par défaut)
    redirect_to(params[:back].presence || dashboard_path, notice: "Projet retiré de vos projets disponibles.")
  end

  def reject
    # On cherche le projet grâce à l'id dans l'URL
    project = Project.find(params[:id])

    # On cherche la candidature à refuser
    maker_project = MakerProject.find(params[:maker_project_id])
    # un message auto généré dans le chat, envoyé par le dreamer au maker :
    match_chat = maker_project.match_chat
    MatchMessage.create(
      content: "Bonjour, Malheureusement votre demande sur ce projet n'a pas été acceptée, mais peut-être pour une prochaine fois !",
      match_chat: match_chat,
      user: current_user
    )

    # Sécurité : seul le dreamer propriétaire du projet peut refuser
    # if project.dreamer != current_user
    #   redirect_to project_path(project), alert: "Vous n'êtes pas autorisé."
    #   return
    # end

    # On change le statut à "rejected"
    maker_project.update!(status: "rejected")

    # Retour sur la page du projet
    redirect_to project_path(project), notice: "Candidature refusée."
  end
end
