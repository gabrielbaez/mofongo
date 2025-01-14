class LeaderboardsController < ApplicationController
  def index
    @top_users = User.joins(:achievements)
                     .select('users.*, COUNT(achievements.id) as achievements_count, SUM(achievements.points) as total_points')
                     .group('users.id')
                     .order('total_points DESC, achievements_count DESC')
                     .limit(50)
    
    @categories = Achievement::CATEGORIES
    
    if params[:category].present? && @categories.key?(params[:category].to_sym)
      @achievements = Achievement.where(category: params[:category])
                               .order(points: :desc)
    end
    
    @current_user_rank = User.joins(:achievements)
                            .select('users.id')
                            .group('users.id')
                            .having('SUM(achievements.points) > ?', current_user&.total_points.to_i)
                            .count + 1 if user_signed_in?
  end
end
