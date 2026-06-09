class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :projects, foreign_key: "dreamer_id"
  has_many :maker_projects, foreign_key: "maker_id"
  has_many :matched_projects, through: :maker_projects, source: :project
  has_many :match_messages

  SKILLS = [
    "Menuiserie", "Ébénisterie", "Tournage sur bois", "Sculpture sur bois",
    "Ferronnerie", "Soudure", "Bijouterie / Joaillerie",
    "Couture / Tapisserie", "Broderie", "Tricot / Crochet",
    "Poterie / Céramique", "Soufflage de verre",
    "Impression 3D", "Gravure laser", "Sérigraphie",
    "Peinture décorative", "Plomberie", "Électricité",
    "Mécanique", "Électronique", "Programmation"
  ]

  validates :role, inclusion: { in: %w[dreamer maker] }

  def dreamer?
    role == "dreamer"
  end

  def maker?
    role == "maker"
  end

  # Average rating this maker received from dreamers (nil if not rated yet)
  def average_rating
    maker_projects.where.not(rating: nil).average(:rating)
  end

  # How many ratings this maker received
  def ratings_count
    maker_projects.where.not(rating: nil).count
  end

  # Ids of the chats this user takes part in (as a maker or as a dreamer)
  def participating_chat_ids
    if dreamer?
      MatchChat.joins(maker_project: :project)
               .where(projects: { dreamer_id: id }).pluck(:id)
    else
      MatchChat.joins(:maker_project)
               .where(maker_projects: { maker_id: id }).pluck(:id)
    end
  end

  # Number of messages this user received and has not read yet
  def unread_messages_count
    MatchMessage.where(match_chat_id: participating_chat_ids, read: false)
                .where.not(user_id: id)
                .count
  end
end
