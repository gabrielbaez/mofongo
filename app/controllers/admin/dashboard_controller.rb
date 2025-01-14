module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @admin_count = User.administrator.count
      @moderator_count = User.moderator.count
      @user_count = User.user.count
      @new_users_24h = User.where('created_at > ?', 24.hours.ago).count
      @active_users_24h = User.where('last_sign_in_at > ?', 24.hours.ago).count
    end
  end
end
