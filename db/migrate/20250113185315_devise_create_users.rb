class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## User profile fields
      t.string :name
      t.date :date_of_birth
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :email
      t.integer :role_id, default: 0  # 0: user, 1: moderator, 2: administrator

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :username,             unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
