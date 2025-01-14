class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :turbo_stream
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    # Set role based on whether this is the first user
    resource.role_id = User.count.zero? ? :administrator : :user

    # Set terms of service from params
    resource.terms_of_service = params[:user][:terms_of_service] == "1"

    if resource.save
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        
        respond_to do |format|
          format.turbo_stream { 
            render turbo_stream: turbo_stream.redirect_to(after_sign_up_path_for(resource))
          }
          format.html { 
            redirect_to after_sign_up_path_for(resource), notice: 'Welcome! You have signed up successfully.'
          }
        end
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        
        respond_to do |format|
          format.turbo_stream { 
            render turbo_stream: turbo_stream.redirect_to(after_inactive_sign_up_path_for(resource))
          }
          format.html { 
            redirect_to after_inactive_sign_up_path_for(resource)
          }
        end
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("registration_form", 
            partial: "devise/registrations/form", 
            locals: { resource: resource, resource_name: :user }
          )
        }
        format.html {
          render :new
        }
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :email, :password, :password_confirmation, :terms_of_service])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :name, :email, :password, :password_confirmation, :current_password])
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_inactive_sign_up_path_for(resource)
    profile_path
  end
end
