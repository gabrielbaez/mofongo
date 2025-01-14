class FollowMailer < ApplicationMailer
  def new_follower
    @follow = params[:follow]
    @follower = @follow.follower
    @user = @follow.followed
    
    mail(
      to: @user.email,
      subject: "#{@follower.display_name} is now following you!"
    )
  end
end
