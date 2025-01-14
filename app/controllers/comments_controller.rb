class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog_post
  before_action :set_comment, only: [:update, :destroy]

  def create
    @comment = @blog_post.comments.build(comment_params)
    @comment.user = current_user

    # Verify ReCAPTCHA if it's a root comment (not a reply)
    if @comment.parent_id.nil? && !verify_recaptcha(model: @comment)
      flash[:alert] = 'Please verify that you are not a robot.'
      redirect_to blog_post_path(@blog_post) and return
    end

    if @comment.save
      flash[:notice] = 'Comment posted successfully.'
    else
      flash[:alert] = 'Error posting comment.'
    end

    redirect_to blog_post_path(@blog_post)
  end

  def update
    if @comment.user == current_user && @comment.update(comment_params)
      flash[:notice] = 'Comment updated successfully.'
    else
      flash[:alert] = 'Error updating comment.'
    end

    redirect_to blog_post_path(@blog_post)
  end

  def destroy
    if @comment.user == current_user
      @comment.destroy
      flash[:notice] = 'Comment deleted successfully.'
    else
      flash[:alert] = 'You are not authorized to delete this comment.'
    end

    redirect_to blog_post_path(@blog_post)
  end

  private

  def set_blog_post
    @blog_post = BlogPost.published.find_by!(slug: params[:blog_post_id])
  end

  def set_comment
    @comment = @blog_post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
