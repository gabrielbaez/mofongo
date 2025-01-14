module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?
    helper_method :moderator_or_admin?
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def moderator_or_admin?
    user_signed_in? && current_user.moderator_or_admin?
  end

  def require_admin
    unless admin?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  def require_moderator
    unless moderator_or_admin?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end
end
