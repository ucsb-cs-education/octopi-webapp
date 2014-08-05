class UnlocksController < ApplicationController
  load_and_authorize_resource :school_class

  def create
    error = nil
    student = Student.find(params[:unlock][:student_id])
    unlockable_type = params[:unlock][:unlockable_type]
    unlockable_id = params[:unlock][:unlockable_id]
    authorize! :edit, @school_class

    if %w(Page Task).include? unlockable_type
      unlockable = unlockable_type.constantize.find(unlockable_id)
      if @school_class.students.include? student
        if (unlockable.is_a? Task) || (unlockable.is_a? ActivityPage)
          unlockable_module = unlockable
          while unlockable_module.type != 'ModulePage'
            unlockable_module = unlockable_module.parent
          end
          if @school_class.module_pages.include? unlockable_module
            begin
              @unlock = Unlock.create(student_id: params[:unlock][:student_id],
                                      school_class_id: params[:school_class_id],
                                      unlockable_type: params[:unlock][:unlockable_type],
                                      unlockable_id: params[:unlock][:unlockable_id])
            rescue ActiveRecord::RecordNotUnique => e
              js false
              render text: 'Cannot create duplicate unlocks. Button may have been pressed too many times',
                     status: :bad_request
            end
          else
            error = 'School class does not contain module that unlockable belongs to'
          end
        else
          error = 'Unlockable id loaded invalid unlockable type'
        end
      else
        error = 'School class does not contain student'
      end
    else
      error = 'Unlockable type is not a valid type (Page, Task)'
    end

    if error || @unlocks.errors.any?
      if error
        render text: error, status: :bad_request
      else
        bad_request_with_errors @unlocks
      end
    else
      respond_to do |format|
        format.html { redirect_to (@unlock) }
        format.js do
          js false
          if params[:unlock][:from_student_progress_view] == 'true'
            render :action => 'create_from_student_progress_view'
          end
        end
      end
    end
  end


end