class CreateAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :badge_icon, null: false
      t.integer :points, null: false, default: 0
      t.string :category, null: false

      t.timestamps
    end

    add_index :achievements, :name, unique: true
    add_index :achievements, :category
  end
end
