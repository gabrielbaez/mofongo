class CreateGalleryImages < ActiveRecord::Migration[7.1]
  def change
    create_table :gallery_images do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :alt_text
      t.integer :width
      t.integer :height
      t.string :content_type
      t.integer :file_size

      t.timestamps
    end
  end
end
