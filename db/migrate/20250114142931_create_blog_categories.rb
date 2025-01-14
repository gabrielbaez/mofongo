class CreateBlogCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_categories do |t|
      t.string :name
      t.text :description
      t.string :slug

      t.timestamps
    end
  end
end
