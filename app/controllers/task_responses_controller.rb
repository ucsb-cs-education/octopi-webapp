class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response
  before_action :verify_assessment_task, only: [:show]
  #Im going to scope only being able to see ones that provide feedback into ability.rb

  def show
    @student = Student.find(@task_response.student)
    @school_class = @task_response.school_class
    @assessment_task = AssessmentTask.find(@task_response.task)
    @activity_page = @assessment_task.activity_page
    @module_page = @activity_page.module_page
    @assessment_question_responses = @task_response.assessment_question_responses
  end

  def index
    if params['task'].present?
      authorize! :read, @task = Task.find(params['task'])
      @school_classes = SchoolClass.accessible_by(@current_ability)
      @task_responses = @task_responses.where(task: @task)
      @response_map = @school_classes.map { |sc|
        {:name => sc.name, :responses => @task_responses.where(school_class: sc).map {|tr|
          {:student_name => tr.student.name,:response_id => tr.id }
        }}
      }
    else
      #list them all? Could be ALOT of data.
    end
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

  def verify_assessment_task
    unless @task_response.task.is_a?(AssessmentTask)
      flash[:warning] = "You cannot view that page."
      redirect_to root_path
    end
  end
end
