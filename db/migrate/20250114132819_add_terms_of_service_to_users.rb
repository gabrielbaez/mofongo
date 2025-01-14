class AddTermsOfServiceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :terms_of_service, :boolean, null: false, default: false
  end
end