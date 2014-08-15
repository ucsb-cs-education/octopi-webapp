module Ckeditor::BaseExtension
  extend ActiveSupport::Concern
  included do
    remove_method :index
    remove_method :create
  end

  def resource_params
    unless @_resource_params
      @_resource_params = {resource: nil}
      _resource_params = params.require(:resource).permit(:id, :type)
      _resource_params[:resource_id] = _resource_params.delete(:id)
      _resource_params[:resource_type] = _resource_params.delete(:type)
      unless _resource_params[:resource_id].nil? && _resource_params[:resource_type].nil?
        succeeded = false
        if _resource_params[:resource_type] == 'CurriculumPage'
          begin
            resource = _resource_params[:resource_type].constantize.find(_resource_params[:resource_id])
            authorize! :edit, resource
            @_resource_params[:resource] = resource
            succeeded = true
          rescue NoMethodError, ActiveRecord::RecordNotFound, CanCan::AccessDenied => e
            # ignored
          end
        end
        unless succeeded
          raise ActionController::BadRequest, 'Invalid resource parameters passed for ckeditor asset creation'
        end
      end
    end
    @_resource_params
  end
end
