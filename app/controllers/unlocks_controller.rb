class UnlocksController < ApplicationController
  load_and_authorize_resource :school_class

  def create
    if @unlock = Unlock.create(student_id: params[:unlock][:student_id],
                               school_class_id: params[:school_class_id],
                               unlockable_type: params[:unlock][:unlockable_type],
                               unlockable_id: params[:unlock][:unlockable_id])
      respond_to do |format|
        format.html { redirect_to @unlock }
        format.js do
          js false
        end
      end
    end
  end
end