class UnlocksController < ApplicationController
  load_and_authorize_resource :school_class

  def create
    begin
      @unlock = Unlock.create(student_id: params[:unlock][:student_id],
                              school_class_id: params[:school_class_id],
                              unlockable_type: params[:unlock][:unlockable_type],
                              unlockable_id: params[:unlock][:unlockable_id])
      if @unlock.errors.empty?
        respond_to do |format|
          format.html { redirect_to (@unlock) }
          unless params[:unlock][:from_student_progress_view] == "true"
            format.js do
              js false
            end
          else
            format.js do
              render :action => "create_from_student_progress_view"
              js false
            end
          end
        end
      end
    rescue ActiveRecord::RecordNotUnique => e
      render text: 'Cannot create duplicate unlocks. Button may have been pressed too many times', status: :bad_request
      js false
    end
  end


end