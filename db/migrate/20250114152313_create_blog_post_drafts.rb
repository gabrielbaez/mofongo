class CreateBlogPostDrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_post_drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :blog_post, foreign_key: true
      t.string :title
      t.text :content
      t.text :summary
      t.string :tag_list
      t.integer :blog_series_id
      t.datetime :last_edited_at

      t.timestamps
    end
  end
end
