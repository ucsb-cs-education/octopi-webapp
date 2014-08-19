class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response

  def reset
    begin
      TaskResponse.transaction do
        #path is still messed up, but it is functional
        #@task_response = TaskResponse.find(params[:id])
        @school_class = SchoolClass.find(params[:task_response_id])
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