class BlogPostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :feed, :archive]
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  
  def index
    @blog_posts = BlogPost.published
                         .includes(:user, :tags)
                         .order(published_at: :desc)
                         .page(params[:page])
    
    if params[:tag].present?
      @blog_posts = @blog_posts.tagged_with(params[:tag])
    end
    
    if params[:series_id].present?
      @blog_posts = @blog_posts.where(blog_series_id: params[:series_id])
    end
    
    set_meta_tags(
      title: "Blog Posts",
      description: "Discover insightful articles on various topics",
      type: "website"
    )
  end
  
  def show
    @blog_post.increment!(:views_count) unless current_user&.id == @blog_post.user_id
    @comments = @blog_post.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
    
    set_meta_tags(
      title: @blog_post.title,
      description: @blog_post.summary.presence || truncate(strip_tags(@blog_post.content), length: 160),
      type: "article",
      image: @blog_post.featured_image_url,
      published_time: @blog_post.published_at,
      author: @blog_post.user.display_name,
      tags: @blog_post.tags.pluck(:name)
    )
  end
  
  def new
    @blog_post = current_user.blog_posts.new
    @draft = current_user.blog_post_drafts.new
  end
  
  def create
    @blog_post = current_user.blog_posts.new(blog_post_params)
    @blog_post.published_at = Time.current if @blog_post.published?
    
    if @blog_post.save
      delete_draft
      redirect_to @blog_post, notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @draft = BlogPostDraft.find_or_initialize_for(@blog_post)
  end
  
  def update
    if @blog_post.update(blog_post_params)
      @blog_post.update(published_at: Time.current) if @blog_post.published? && @blog_post.published_at.nil?
      delete_draft
      redirect_to @blog_post, notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @blog_post.destroy
    redirect_to blog_posts_url, notice: "Blog post was successfully deleted."
  end
  
  def autosave
    @draft = current_user.blog_post_drafts.find_or_initialize_by(
      blog_post_id: params[:id]
    )
    
    @draft.assign_attributes(draft_params)
    
    if @draft.save
      render json: { success: true, id: @draft.blog_post_id }
    else
      render json: { success: false, errors: @draft.errors }, status: :unprocessable_entity
    end
  end
  
  def upload_image
    if params[:file]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: params[:file],
        filename: params[:file].original_filename,
        content_type: params[:file].content_type
      )
      
      render json: {
        url: url_for(blob),
        success: true
      }
    else
      render json: {
        success: false,
        message: "No file provided"
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end
  
  def blog_post_params
    params.require(:blog_post).permit(
      :title,
      :content,
      :summary,
      :published,
      :blog_series_id,
      :tag_list
    )
  end
  
  def draft_params
    params.require(:blog_post).permit(
      :title,
      :content,
      :summary,
      :tag_list,
      :blog_series_id
    )
  end
  
  def authorize_user!
    unless current_user.id == @blog_post.user_id
      redirect_to blog_posts_url, alert: "You are not authorized to perform this action."
    end
  end
  
  def delete_draft
    current_user.blog_post_drafts.find_by(blog_post_id: @blog_post.id)&.destroy
  end
  
  def set_meta_tags(options = {})
    content_for :meta_title, options[:title]
    content_for :meta_description, options[:description]
    content_for :meta_type, options[:type]
    content_for :meta_image, options[:image] if options[:image].present?
    content_for :meta_published_time, options[:published_time] if options[:published_time].present?
    content_for :meta_author, options[:author] if options[:author].present?
    content_for :meta_tags, options[:tags] if options[:tags].present?
  end
end
