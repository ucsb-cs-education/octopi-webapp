class Staff::ConfirmationsController < Devise::ConfirmationsController

  def show
    if params[:confirmation_token]
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        if resource.errors[:email].present? && resource.persisted?
          resource.resend_confirmation_instructions
          set_flash_message(:notice, :send_instructions) if is_flashing_format?
          set_flash_message(:info, :resent_instructions, email: resource.email) if is_flashing_format?
          respond_with_navigational(resource, status: :unprocessable_entity)
        else
          set_flash_message(:alert, :no_matching_account) if is_flashing_format?
          respond_with_navigational(resource.errors, status: :unprocessable_entity)
        end
      end
    end
  end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    staff_confirmation_path
  end
end