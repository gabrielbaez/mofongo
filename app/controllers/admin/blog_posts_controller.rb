class Admin::BlogPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog_post, only: [:edit, :update, :destroy]

  def index
    @blog_posts = current_user.blog_posts.includes(:blog_category)
  end

  def new
    @blog_post = current_user.blog_posts.build
  end

  def create
    @blog_post = current_user.blog_posts.build(blog_post_params)
    
    if @blog_post.save
      redirect_to admin_blog_posts_path, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_posts_path, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: 'Post was successfully deleted.'
  end

  private

  def set_blog_post
    @blog_post = current_user.blog_posts.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :content, :blog_category_id, :published, :tag_names)
  end
end
