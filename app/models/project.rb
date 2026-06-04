class Project < ApplicationRecord
  belongs_to :dreamer, class_name: "User"
  has_many :llm_chats, dependent: :destroy
  has_many :maker_projects, dependent: :destroy
  has_one_attached :image

  # True when at least one maker has been accepted on this project
  def matched?
    maker_projects.any? { |mp| mp.status == "accepted" }
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
