class SubscriptionMailer < ApplicationMailer
  def confirmation
    @subscription = params[:subscription]
    mail(
      to: @subscription.email,
      subject: "Please confirm your blog subscription"
    )
  end

  def welcome_email
    @subscription = params[:subscription]
    mail(
      to: @subscription.email,
      subject: "Welcome to Mofongo Blog!"
    )
  end

  def new_post
    @subscription = params[:subscription]
    @blog_post = params[:blog_post]
    mail(
      to: @subscription.email,
      subject: "New blog post: #{@blog_post.title}"
    )
  end
  
  def weekly_digest
    @subscription = params[:subscription]
    @start_date = 1.week.ago.beginning_of_week
    @end_date = Time.current.end_of_week
    
    @blog_posts = BlogPost.published
                         .where(published_at: @start_date..@end_date)
                         .order(published_at: :desc)
    
    return if @blog_posts.empty?
    
    @popular_posts = BlogPost.published
                            .where(published_at: @start_date..@end_date)
                            .joins(:likes)
                            .group('blog_posts.id')
                            .order('COUNT(likes.id) DESC')
                            .limit(3)
    
    mail(
      to: @subscription.email,
      subject: "Your Weekly Blog Digest - #{@start_date.strftime('%B %-d')}"
    )
  end
  
  def series_update
    @subscription = params[:subscription]
    @blog_series = params[:blog_series]
    @blog_post = params[:blog_post]
    
    mail(
      to: @subscription.email,
      subject: "New post in series: #{@blog_series.title}"
    )
  end
  
  def community_highlights
    @subscription = params[:subscription]
    @start_date = 1.week.ago
    
    @top_comments = Comment.where(created_at: @start_date..Time.current)
                          .joins(:likes)
                          .group('comments.id')
                          .order('COUNT(likes.id) DESC')
                          .limit(5)
    
    @top_contributors = User.joins(:blog_posts)
                           .where(blog_posts: { published_at: @start_date..Time.current })
                           .group('users.id')
                           .order('COUNT(blog_posts.id) DESC')
                           .limit(3)
    
    return if @top_comments.empty? && @top_contributors.empty?
    
    mail(
      to: @subscription.email,
      subject: "Community Highlights - #{Time.current.strftime('%B %-d')}"
    )
  end
end
