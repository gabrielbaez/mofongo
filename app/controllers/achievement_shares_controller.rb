class AchievementSharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_achievement
  
  def create
    @share = AchievementShare.new(
      user_achievement: @user_achievement,
      message: params[:message]
    )
    
    if @share.save
      flash[:notice] = "Achievement shared successfully!"
    else
      flash[:alert] = "Could not share achievement."
    end
    
    redirect_back(fallback_location: profile_path(current_user))
  end
  
  private
  
  def set_user_achievement
    @user_achievement = current_user.user_achievements.find(params[:user_achievement_id])
  end
end
