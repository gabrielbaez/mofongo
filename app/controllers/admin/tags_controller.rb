class Admin::TagsController < Admin::BaseController
  before_action :authenticate_user!
  before_action :set_tag, only: [:show, :edit, :update, :destroy, :merge]
  
  def index
    @tags = Tag.includes(:taggings)
               .select('tags.*, COUNT(taggings.id) as usage_count')
               .left_joins(:taggings)
               .group('tags.id')
               .order('usage_count DESC, name ASC')
               .page(params[:page])
               .per(50)
  end
  
  def show
    @tagged_posts = BlogPost.tagged_with(@tag.name)
                           .includes(:user)
                           .order(created_at: :desc)
                           .page(params[:page])
  end
  
  def new
    @tag = Tag.new
  end
  
  def create
    @tag = Tag.new(tag_params)
    
    if @tag.save
      redirect_to admin_tags_path, notice: "Tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: "Tag was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @tag.destroy
    redirect_to admin_tags_path, notice: "Tag was successfully deleted."
  end
  
  def merge
    if params[:target_tag_id].present?
      target_tag = Tag.find(params[:target_tag_id])
      
      Tag.transaction do
        # Update all taggings to point to the target tag
        @tag.taggings.update_all(tag_id: target_tag.id)
        
        # Delete the old tag
        @tag.destroy
      end
      
      redirect_to admin_tags_path, notice: "Tags were successfully merged."
    else
      @target_tags = Tag.where.not(id: @tag.id).order(:name)
      render :merge
    end
  end
  
  def search
    query = params[:q].to_s.strip
    @tags = Tag.where('name ILIKE ?', "%#{query}%").limit(10)
    
    render json: @tags.map { |tag| { id: tag.id, name: tag.name } }
  end
  
  private
  
  def set_tag
    @tag = Tag.find(params[:id])
  end
  
  def tag_params
    params.require(:tag).permit(:name, :description, :featured)
  end
end
