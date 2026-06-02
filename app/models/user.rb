class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :projects, foreign_key: "dreamer_id"
  has_many :maker_projects, foreign_key: "maker_id"
  has_many :match_messages
end
