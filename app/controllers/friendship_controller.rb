class FriendshipController < ApplicationController
  def create
    friend = User.find_friend_id(params[:name])
    @friendship = Friendship.create(user_id: params[:user_id], friend_id: friend)
    if @friendship.save
      flash[:success] = "Your friendship was added successfully!"
      redirect_to dashboard_path
    else
      flash[:error] = "ERROR: Your friendship was not saved!"
      redirect_to dashboard_path
    end
  end
end
