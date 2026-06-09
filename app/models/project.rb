class Project < ApplicationRecord
  belongs_to :dreamer, class_name: "User"
  has_one :llm_chat, dependent: :destroy
  has_many :maker_projects, dependent: :destroy
  has_one_attached :image

  # The maker application engaged on this project (accepted, made or
  # delivered), if there is one. There can only be one at a time.
  def engaged_maker_project
    maker_projects.find { |mp| MakerProject::ENGAGED_STATUSES.include?(mp.status) }
  end

  # True when a maker is engaged on this project (accepted, made or delivered)
  def matched?
    engaged_maker_project.present?
  end

  # True when this maker can still match or dismiss this project.
  # False if the project is already matched, or if this maker already acted on it.
  def open_for?(maker)
    return false if matched?
    maker_projects.none? { |mp| mp.maker_id == maker.id }
  end

  # A simple status label, based on the makers' applications
  def status_label
    case engaged_maker_project&.status
    when "delivered" then "Livré"
    when "made"      then "Réalisé"
    when "accepted"  then "Match trouvé"
    else
      maker_projects.any? ? "Candidatures reçues" : "En attente de maker"
    end
  end
end
