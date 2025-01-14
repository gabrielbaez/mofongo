class Admin::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:approve, :destroy]

  def index
    @comments = Comment.includes(:blog_post, :user)
                      .where(approved: false)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
  end

  def approve
    @comment.update(approved: true, approved_at: Time.current)
    redirect_to admin_comments_path, notice: 'Comment approved successfully.'
  end

  def destroy
    @comment.destroy
    redirect_to admin_comments_path, notice: 'Comment deleted successfully.'
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
