module Admin
  class AdminController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :ensure_admin

    def dashboard
      # Total users
      @total_users = User.count
      
      # User stats
      @new_users_today = User.where('created_at >= ?', Time.current.beginning_of_day).count
      @new_users_this_week = User.where('created_at >= ?', Time.current.beginning_of_week).count
      @new_users_this_month = User.where('created_at >= ?', Time.current.beginning_of_month).count
      
      # Role distribution
      @role_distribution = {
        'Admin' => User.where(role_id: :administrator).count,
        'Moderator' => User.where(role_id: :moderator).count,
        'User' => User.where(role_id: :user).count
      }
      
      # Recent users
      @recent_users = User.order(created_at: :desc).limit(5)
    end

    private

    def ensure_admin
      unless current_user&.administrator?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end
  end
end
