class Staff::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    if Rails.env.production?
      sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, protocol: 'https')
    else
      sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, protocol: 'http' )
    end
    redirect_url = stored_location_for(resource) || request.referer || staff_root_path
    redirect_url = super if redirect_url == sign_in_url
    redirect_url = staff_root_path if redirect_url == sign_in_url
    redirect_url
  end
end