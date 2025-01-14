namespace :setup do
  desc 'Create default admin user'
  task create_admin: :environment do
    # Try to find existing user by username or email
    user = User.find_by(username: 'admin') || User.find_by(email: 'admin@somewhereemail.com')

    if user
      # Update existing user
      user.update!(
        email: 'admin@somewhereemail.com',
        name: 'Administrator',
        terms_of_service: true
      )
      user.update_column(:role_id, User.role_ids[:administrator])
      puts "Existing admin user updated successfully!"
    else
      # Create new user with admin role
      user = User.new(
        username: 'admin',
        email: 'admin@somewhereemail.com',
        name: 'Administrator',
        password: 'welcome1',
        password_confirmation: 'welcome1',
        terms_of_service: true
      )

      # Save without validations first to ensure the user exists
      if user.save(validate: false)
        # Now set the role and confirm the user
        user.update_column(:role_id, User.role_ids[:administrator])
        user.confirm if user.respond_to?(:confirm)
        
        puts "New admin user created successfully!"
      else
        puts "Error creating admin user:"
        puts user.errors.full_messages
        exit 1
      end
    end

    # Ensure user is confirmed
    user.confirm if user.respond_to?(:confirm) && !user.confirmed?
    
    puts "Admin user is ready!"
    puts "Email: admin@somewhereemail.com"
    puts "Password: welcome1 (only for new users)"
  end
end
