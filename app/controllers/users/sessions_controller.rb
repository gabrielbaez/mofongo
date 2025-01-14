class Users::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.redirect_to(after_sign_in_path_for(resource))
      }
      format.html { 
        set_flash_message!(:notice, :signed_in)
        respond_with resource, location: after_sign_in_path_for(resource)
      }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.redirect_to(after_sign_out_path_for(resource_name))
      }
      format.html {
        set_flash_message! :notice, :signed_out if signed_out
        redirect_to after_sign_out_path_for(resource_name), status: :see_other
      }
    end
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
