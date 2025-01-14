class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find_by!(username: params[:id])
    @comment_stats = @user.comment_stats
    @recent_comments = @user.recent_comments(10)
    @recent_posts = @user.recent_blog_posts(5)
    
    # Check for new achievements
    @user.check_achievements if @user == current_user
  end

  private

  # def set_user
  #   @user = User.find_by!(username: params[:id])
  # end
end
