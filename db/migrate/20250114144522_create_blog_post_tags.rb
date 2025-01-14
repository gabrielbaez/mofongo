class CreateBlogPostTags < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_post_tags do |t|
      t.references :blog_post, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :blog_post_tags, [:blog_post_id, :tag_id], unique: true
  end
end
