class OctopiWardenFailure < Devise::FailureApp
  def redirect_url
    if warden_message == :unconfirmed
      staff_confirmation_path
    else
      super
    end
  end
end