class Admin::GalleryImagesController < Admin::BaseController
  before_action :set_gallery_image, only: [:show, :edit, :update, :destroy]
  
  def index
    @gallery_images = GalleryImage.includes(:user)
                                .order(created_at: :desc)
                                .page(params[:page])
                                .per(24)
  end
  
  def show
    @usage = BlogPost.where("content LIKE ?", "%#{@gallery_image.original_url}%")
                    .or(BlogPost.where("content LIKE ?", "%#{@gallery_image.medium_url}%"))
                    .includes(:user)
                    .order(created_at: :desc)
  end
  
  def edit
  end
  
  def update
    if @gallery_image.update(gallery_image_params)
      redirect_to admin_gallery_image_path(@gallery_image), notice: "Image was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @gallery_image.destroy
    redirect_to admin_gallery_images_path, notice: "Image was successfully deleted."
  end
  
  private
  
  def set_gallery_image
    @gallery_image = GalleryImage.find(params[:id])
  end
  
  def gallery_image_params
    params.require(:gallery_image).permit(:title, :description, :alt_text)
  end
end
