class GithubFacade

  def initialize(current_user)
    @access_token = current_user[:github_token]
    @_followers = nil
    @_repos = nil
    @_followings = nil
    @current_user = current_user
  end

  def repos
    find_repos.map do |repo|
      Repository.new(repo)
    end
  end

  def followers
    find_followers.map do |follower|
      Follower.new(follower)
    end
  end

  def followings
    find_followings.map do |following|
      Following.new(following)
    end
  end

  def user_check(user)
    User.exists?(github_uid: user.name)
  end

  def friend_check(user)
    user_id = User.find_friend_id(user.name)
    Friendship.where('user_id = ? AND friend_id = ?', @current_user.id, user_id).exists?
  end

  def friends
    User.find(@current_user.id).friends
  end

  private

  def find_repos
    @_repos ||= service.repos
  end

  def find_followers
    @_followers ||= service.followers
  end

  def find_followings
    @_followings ||= service.followings
  end

  def service
    GithubService.new(@access_token)
  end
end
