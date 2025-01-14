class AddFieldsToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :name, :string
    add_column :subscriptions, :preferences, :string, array: true, default: []
    add_column :subscriptions, :metadata, :jsonb, default: {}
    
    add_index :subscriptions, :preferences, using: 'gin'
  end
end
