class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment
  
  def create
    @vote = @comment.votes.find_or_initialize_by(user: current_user)
    @vote.value = params[:value].to_i
    
    if @vote.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "comment-#{@comment.id}-votes",
            partial: "comments/votes",
            locals: { comment: @comment }
          )
        }
        format.html { redirect_back(fallback_location: root_path) }
      end
    else
      redirect_back fallback_location: root_path, alert: "Unable to vote"
    end
  end
  
  def destroy
    @vote = @comment.votes.find_by(user: current_user)
    @vote&.destroy
    
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "comment-#{@comment.id}-votes",
          partial: "comments/votes",
          locals: { comment: @comment }
        )
      }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
  
  private
  
  def set_comment
    @comment = Comment.find(params[:comment_id])
  end
end
