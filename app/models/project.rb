class Project < ApplicationRecord
  belongs_to :dreamer, class_name: "User"
  has_one :llm_chat, dependent: :destroy
  has_many :maker_projects, dependent: :destroy
  has_one_attached :image

  # True when at least one maker has been accepted on this project
  def matched?
    maker_projects.any? { |mp| mp.status == "accepted" }
  end

  # True when this maker can still match or dismiss this project.
  # False if the project is already matched, or if this maker already acted on it.
  def open_for?(maker)
    return false if matched?
    maker_projects.none? { |mp| mp.maker_id == maker.id }
  end

  # A simple status label, based on the makers' applications
  def status_label
    if matched?
      "Match trouvé"
    elsif maker_projects.any?
      "Candidatures reçues"
    else
      "En attente de maker"
    end
  end
end
