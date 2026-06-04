class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :projects, foreign_key: "dreamer_id"
  has_many :maker_projects, foreign_key: "maker_id"
  has_many :matched_projects, through: :maker_projects, source: :project
  has_many :match_messages

  validates :role, inclusion: { in: %w[dreamer maker] }

  def dreamer?
    role == "dreamer"
  end

  def maker?
    role == "maker"
  end
end
