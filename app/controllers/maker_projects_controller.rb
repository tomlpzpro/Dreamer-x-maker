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
    # First message, auto-sent by the maker to introduce his interest
    MatchMessage.create(
      content: "#{current_user.username} aimerait vous aider à créer #{project.title}.",
      match_chat: chat,
      user: current_user
    )

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

  # Le maker indique que le projet est réalisé (accepted -> made)
  def mark_made
    advance_maker_project(
      from: "accepted",
      to: "made",
      message: lambda { |project|
        "#{current_user.username} a terminé de réaliser votre #{project.title}. " \
          "Echangez pour convenir d'un mode de réception !"
      },
      notice: "Projet marqué comme réalisé !"
    )
  end

  # Le dreamer ouvre le formulaire de réception (photo + note du maker).
  # Possible seulement par le dreamer du projet, quand le projet est "made".
  def delivery
    @project = Project.find(params[:id])
    @maker_project = @project.engaged_maker_project
    # "made" = first reception, "delivered" = editing the rating/photo afterwards
    return if current_user == @project.dreamer && ["made", "delivered"].include?(@maker_project&.status)

    redirect_to project_path(@project), alert: "Action impossible."
  end

  # Le dreamer confirme la réception (made -> delivered) : il enregistre sa
  # note et la photo du projet fini, qui apparaîtront sur la page du maker.
  def mark_delivered
    project = Project.find(params[:id])
    maker_project = project.engaged_maker_project

    unless current_user == project.dreamer && ["made", "delivered"].include?(maker_project&.status)
      redirect_to project_path(project), alert: "Action impossible." and return
    end

    first_reception = maker_project.status == "made"
    maker_project.update!(status: "delivered", rating: params[:rating])
    maker_project.delivery_photo.attach(params[:delivery_photo]) if params[:delivery_photo].present?
    # Only notify the maker on the first reception, not when the dreamer edits
    notify_delivery(project, maker_project) if first_reception
    notice = first_reception ? "Réception confirmée, merci pour votre note !" : "Note et photo mises à jour !"
    redirect_to maker_path(maker_project.maker), notice: notice
  end

  private

  # Message auto envoyé dans le chat quand le dreamer a bien reçu le projet
  def notify_delivery(project, maker_project)
    MatchMessage.create(
      content: "#{project.dreamer.username} a bien reçu « #{project.title} ». " \
               "Merci #{maker_project.maker.username} pour cette réalisation !",
      match_chat: maker_project.match_chat,
      user: current_user
    )
  end

  # Le maker connecté fait avancer SA candidature d'un statut au suivant,
  # et prévient le dreamer dans le chat. On vérifie le statut de départ.
  # `message` est une petite fonction qui reçoit le projet et renvoie le texte.
  def advance_maker_project(from:, to:, message:, notice:)
    project = Project.find(params[:id])
    maker_project = current_user.maker_projects.find_by!(project: project)

    if maker_project.status == from
      maker_project.update!(status: to)
      MatchMessage.create(content: message.call(project), match_chat: maker_project.match_chat, user: current_user)
      redirect_back fallback_location: project_path(project), notice: notice
    else
      redirect_back fallback_location: project_path(project), alert: "Action impossible."
    end
  end
end
