class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response

  def show
    @student = Student.find(@task_response.student)
    @school_class = @task_response.school_class
    @assessment_task = AssessmentTask.find(@task_response.task)
    @activity_page = @assessment_task.activity_page
    @module_page = @activity_page.module_page
    @assessment_question_responses = @task_response.assessment_question_responses
  end

  def reset
    begin
      TaskResponse.transaction do
        @school_class = SchoolClass.find(params[:school_class_id])
        @task_response.destroy!
        Unlock.find_by(student: @task_response.student, school_class: @school_class, unlockable: @task_response.task).update(hidden: false)
        #For RemoveUnlocks branch
        #@task_response.delete_children!
        #@task_response.update(hidden: false, completed: false)
        flash[:success] = "#{@task_response.student.name}'s progress for #{@task_response.task.title} successfully reset."
        redirect_to(:back)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
end