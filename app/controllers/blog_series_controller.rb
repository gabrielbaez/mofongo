class BlogSeriesController < ApplicationController
  def index
    @blog_series = BlogSeries.includes(:blog_posts)
                            .where(blog_posts: { published: true })
                            .distinct
                            .order(created_at: :desc)
                            .page(params[:page])
  end

  def show
    @blog_series = BlogSeries.find_by!(slug: params[:id])
    @blog_posts = @blog_series.published_posts.includes(:user, :blog_category)
  end
end
