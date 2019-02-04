class User < ApplicationRecord
  has_many :user_videos
  has_many :videos, through: :user_videos

  has_many :followed_users, foreign_key: :follower_id, class_name: 'Friendship'
  has_many :followees, through: :followed_users

  has_many :following_users, foreign_key: :followee_id, class_name: 'Friendship'
  has_many :followers, through: :following_users

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
end
