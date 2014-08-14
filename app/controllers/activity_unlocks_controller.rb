class ActivityUnlocksController < ApplicationController
  load_and_authorize_resource :school_class

  def create
    error = nil
    student = Student.find(params[:activity_unlock][:student_id])
    activity_page = params[:activity_unlock][:activity_page_id]
    authorize! :edit, @school_class

    activity = ActivityPage.find(activity_page)
    activity_unlock = ActivityUnlock.find_by(student: student, school_class: @school_class, activity_page: activity)
    if activity_unlock.nil?
      if @school_class.students.include? student
        activity_module = activity.parent
        if @school_class.module_pages.include? activity_module
          begin
            @unlock = ActivityUnlock.create(student_id: params[:activity_unlock][:student_id],
                                            school_class_id: params[:school_class_id],
                                            activity_page: activity,
                                            unlocked: true)
          rescue ActiveRecord::RecordNotUnique => e
            js false
            render text: 'Cannot create duplicate unlocks. Button may have been pressed too many times',
                   status: :bad_request
          end
        else
          error = 'School class does not contain module that the activity belongs to'
        end
      else
        error = 'School class does not contain student'
      end
    else
      activity_unlock.update(unlocked: true)
      @unlock = activity_unlock
    end


    if error ||@unlock.errors.any?
      if error
        render text: error, status: :bad_request
      else
        bad_request_with_errors @unlock
      end
    else
      respond_to do |format|
        format.html { redirect_to (@unlock) }
        format.js do
          js false
          if params[:activity_unlock][:from_student_progress_view] == 'true'
            render :action => 'create_from_student_progress_view'
          end
        end
      end
    end
  end


end