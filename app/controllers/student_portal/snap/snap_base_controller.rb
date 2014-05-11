class StudentPortal::Snap::SnapBaseController < StudentPortal::BaseController
  respond_to :xml, :json

  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: File.join(Rails.root, 'public/404.html'), status: 404, layout: false
  end

  protected
    alias_method :devise_current_user, :current_user

    def current_user
      current_student || devise_current_user
    end

    def create_post_success_response (status, location)
      respond_to do |format|
        format.xml {
          head status, location: location
        }
        format.json {
          render json: {success: true, location: location}, location: location, status: status
        }
      end
    end

end
