class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :email, null: false
      t.references :user, foreign_key: true
      t.string :token, null: false
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    add_index :subscriptions, :email, unique: true
    add_index :subscriptions, :token, unique: true
  end
end
