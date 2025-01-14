class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.references :notifiable, polymorphic: true, null: false
      t.datetime :read_at

      t.timestamps
    end
    
    add_index :notifications, [:recipient_id, :read_at]
  end
end