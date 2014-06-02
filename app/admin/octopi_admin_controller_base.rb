module OctopiAdminControllerBase

  def insert_controller_actions(options = {})
    controller do
      def edit
        session[:return_to] = request.referer
      end

      def update
        update! do |success, fail|
          success.html { redirect_to session.delete(:return_to) || default_update_path }
        end
      end
    end
  end

end