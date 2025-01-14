class CreateAchievementProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :achievement_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :achievement, null: false, foreign_key: true
      t.integer :current_value, null: false, default: 0
      t.integer :target_value, null: false
      t.datetime :last_updated_at

      t.timestamps
    end

    add_index :achievement_progresses, [:user_id, :achievement_id], unique: true
  end
end
