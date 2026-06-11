module NotificationsHelper
  # One notification: a short text, the page it links to, and the project it
  # belongs to (so the "À faire" panel can group them by project).
  Notification = Struct.new(:text, :path, :project)

  # Status-based actions the user should take (no messages here).
  # Used by the navbar bell.
  def action_notifications(user)
    user.dreamer? ? dreamer_notifications(user) : maker_notifications(user)
  end

  # Everything to look at when landing on the site: the actions above plus the
  # discussions that have unread messages. Used by the dashboard "À faire" panel.
  def notifications_for(user)
    action_notifications(user) + unread_message_notifications(user)
  end

  # Dreamer: applications waiting for a decision, and finished projects to receive
  def dreamer_notifications(user)
    items = []
    user.projects.includes(:maker_projects).each do |project|
      pending = project.maker_projects.count { |mp| mp.status == "pending" }
      if pending.positive?
        items << Notification.new("#{pending} maker(s) ont postulé", project_path(project), project)
      end
      if project.engaged_maker_project&.status == "made"
        items << Notification.new("Projet réalisé : confirmez la réception", delivery_project_path(project), project)
      end
    end
    items
  end

  # Maker: his applications that were accepted (he can start, then mark realised)
  def maker_notifications(user)
    accepted = user.maker_projects.includes(:project).select { |mp| mp.status == "accepted" }
    accepted.map do |mp|
      Notification.new("Vous avez été choisi : marquez-le terminé une fois réalisé", project_path(mp.project), mp.project)
    end
  end

  # Everyone: the discussions that still have unread messages
  def unread_message_notifications(user)
    chats = MatchChat.where(id: user.participating_chat_ids)
                     .includes(:match_messages, maker_project: :project)
    chats.filter_map do |chat|
      count = chat.unread_count_for(user)
      next if count.zero?

      Notification.new("#{count} message(s) non lu(s)", match_chat_path(chat), chat.maker_project.project)
    end
  end
end
