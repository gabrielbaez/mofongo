module ApplicationHelper
  def user_role_color(role)
    case role.to_s
    when 'administrator'
      'danger'
    when 'moderator'
      'warning'
    else
      'primary'
    end
  end
end
