class User < ApplicationRecord
  has_many :user_videos
  has_many :videos, through: :user_videos

  has_many :friendships
  has_many :friends, through: :friendships, class_name: "User"

  validates :email, uniqueness: true, presence: true
  validates_presence_of :password, if: :password
  validates_presence_of :first_name
  enum role: [:default, :admin]
  has_secure_password

  def tutorials
    Tutorial.joins(videos: :users)
            .where(users: {id: self.id})
            .group(:id)
  end

  def self.find_friend_id(name)
    User.where(github_uid: name).pluck(:id).first
  end
end
