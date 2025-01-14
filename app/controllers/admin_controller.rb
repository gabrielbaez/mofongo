class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  
  layout 'admin'
  
  def dashboard
    @total_users = User.count
    @users_by_role = User.group(:role_id).count
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end
