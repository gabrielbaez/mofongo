class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :email, null: false
      t.string :name
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.string :preferences, array: true, default: []
      t.jsonb :metadata, default: {}
      t.references :user, foreign_key: true, null: true

      t.timestamps
    end

    add_index :subscriptions, :email, unique: true
    add_index :subscriptions, :confirmation_token, unique: true
    add_index :subscriptions, :preferences, using: 'gin'
  end
end
