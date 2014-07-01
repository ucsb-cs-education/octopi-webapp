class Staff::ConfirmationsController < Devise::ConfirmationsController

  # POST /resource/confirmation
  def create
    # self.resource = resource_class.send_confirmation_instructions(resource_params)
    self.resource = resource_class.send_confirmation_instructions({email: current_user.email})
    if successfully_sent?(resource)
      respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    resend_url = url_for(:action => 'create', :controller => 'staff/confirmations', :only_path => false, :protocol => 'http')
    if request.referer == resend_url
      root_path
    else
      stored_location_for(resource) || request.referer || admin_staff_index_path
    end
  end
end