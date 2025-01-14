class GalleryImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_gallery_image, only: [:show, :edit, :update, :destroy]
  
  def index
    @gallery_images = current_user.gallery_images.recent.page(params[:page])
  end
  
  def show
  end
  
  def new
    @gallery_image = current_user.gallery_images.new
  end
  
  def create
    @gallery_image = current_user.gallery_images.new(gallery_image_params)
    
    if @gallery_image.save
      if params[:editor_upload]
        render json: {
          url: @gallery_image.medium_url,
          success: true
        }
      else
        redirect_to gallery_images_path, notice: "Image was successfully uploaded."
      end
    else
      if params[:editor_upload]
        render json: {
          success: false,
          errors: @gallery_image.errors.full_messages
        }, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
  
  def edit
  end
  
  def update
    if @gallery_image.update(gallery_image_params)
      redirect_to gallery_images_path, notice: "Image was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @gallery_image.destroy
    redirect_to gallery_images_path, notice: "Image was successfully deleted."
  end
  
  private
  
  def set_gallery_image
    @gallery_image = current_user.gallery_images.find(params[:id])
  end
  
  def gallery_image_params
    params.require(:gallery_image).permit(:title, :description, :alt_text, :image)
  end
end
