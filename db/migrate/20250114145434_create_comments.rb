class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :blog_post, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.string :author_name
      t.string :author_email
      t.boolean :approved, default: false
      t.datetime :approved_at

      t.timestamps
    end

    add_index :comments, [:blog_post_id, :created_at]
  end
end
