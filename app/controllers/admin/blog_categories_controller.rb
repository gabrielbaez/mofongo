class Admin::BlogCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog_category, only: [:edit, :update, :destroy]

  def index
    @blog_categories = BlogCategory.all
  end

  def new
    @blog_category = BlogCategory.new
  end

  def create
    @blog_category = BlogCategory.new(blog_category_params)
    
    if @blog_category.save
      redirect_to admin_blog_categories_path, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_category.update(blog_category_params)
      redirect_to admin_blog_categories_path, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @blog_category.destroy
    redirect_to admin_blog_categories_path, notice: 'Category was successfully deleted.'
  end

  private

  def set_blog_category
    @blog_category = BlogCategory.find(params[:id])
  end

  def blog_category_params
    params.require(:blog_category).permit(:name, :description)
  end
end
