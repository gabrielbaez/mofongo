class CreateAchievementShares < ActiveRecord::Migration[7.1]
  def change
    create_table :achievement_shares do |t|
      t.references :user_achievement, null: false, foreign_key: true
      t.text :message
      t.integer :likes_count, default: 0, null: false

      t.timestamps
    end
  end
end
