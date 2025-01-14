class AchievementMailer < ApplicationMailer
  def achievement_unlocked
    @user_achievement = params[:user_achievement]
    @user = @user_achievement.user
    @achievement = @user_achievement.achievement
    
    mail(
      to: @user.email,
      subject: "🏆 Achievement Unlocked: #{@achievement.name}!"
    )
  end
end
