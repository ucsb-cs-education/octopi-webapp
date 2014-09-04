class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response
  before_action :verify_assessment_task
  #Im going to scope only being able to see ones that provide feedback into ability.rb

  def show
    @student = Student.find(@task_response.student)
    @school_class = @task_response.school_class
    @assessment_task = AssessmentTask.find(@task_response.task)
    @activity_page = @assessment_task.activity_page
    @module_page = @activity_page.module_page
    @assessment_question_responses = @task_response.assessment_question_responses
  end

  def verify_assessment_task
    unless @task_response.task.is_a?(AssessmentTask)
      flash[:warning] = "You cannot view that page."
      redirect_to root_path
    end
  end
end
