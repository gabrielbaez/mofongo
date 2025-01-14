class CreateBlogSeries < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_series do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :blog_series, :slug, unique: true

    add_reference :blog_posts, :blog_series, foreign_key: true
    add_column :blog_posts, :position, :integer
    add_index :blog_posts, [:blog_series_id, :position], unique: true,
      where: "blog_series_id IS NOT NULL AND position IS NOT NULL"
  end
end
