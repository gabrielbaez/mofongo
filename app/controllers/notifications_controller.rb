class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:mark_as_read]
  
  def index
    @notifications = current_user.notifications
                               .includes(:actor, :notifiable)
                               .order(created_at: :desc)
                               .page(params[:page])
  end
  
  def mark_as_read
    @notification.mark_as_read!
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end
  
  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end
  
  private
  
  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
