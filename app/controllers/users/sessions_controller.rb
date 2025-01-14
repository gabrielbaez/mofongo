class Users::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream
  
  # GET /resource/sign_in
  def new
    self.resource = resource_class.new
    respond_to do |format|
      format.html { super }
      format.turbo_stream { 
        render turbo_stream: turbo_stream.update("content", partial: "devise/sessions/form")
      }
    end
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    
    respond_to do |format|
      format.html { 
        set_flash_message!(:notice, :signed_in)
        respond_with resource, location: after_sign_in_path_for(resource)
      }
      format.turbo_stream { 
        redirect_to after_sign_in_path_for(resource)
      }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    
    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.turbo_stream { redirect_to root_path, status: :see_other }
      format.all { head :no_content }
    end
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
