class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  
  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: profile_path(@user)) }
      format.turbo_stream
    end
  end
  
  def destroy
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: profile_path(@user)) }
      format.turbo_stream
    end
  end
  
  private
  
  def set_user
    @user = User.find_by!(username: params[:profile_id])
  end
end
