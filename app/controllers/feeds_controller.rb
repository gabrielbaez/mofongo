class FeedsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @posts = current_user.feed.page(params[:page])
  end
end
