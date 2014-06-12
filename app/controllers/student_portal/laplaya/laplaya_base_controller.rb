class StudentPortal::Laplaya::LaplayaBaseController < StudentPortal::BaseController
  respond_to :json

  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: File.join(Rails.root, 'public/404.html'), status: 404, layout: false
  end

  def current_user
    current_student || current_staff
  end

  protected
    def create_post_success_response (status, location, file_id)
        render json: {success: true, location: location, file_id: file_id}, location: location, status: status
    end

end
