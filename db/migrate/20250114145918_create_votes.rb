class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :votes, [:user_id, :comment_id], unique: true
    
    add_column :comments, :score, :integer, default: 0, null: false
    add_column :comments, :upvotes_count, :integer, default: 0, null: false
    add_column :comments, :downvotes_count, :integer, default: 0, null: false
  end
end
