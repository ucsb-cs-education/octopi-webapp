class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response
  before_action :verify_assessment_task_response, only: [:show]
  before_action :verify_assessment_task, only: [:index]

  def show
    @student = Student.find(@task_response.student)
    @school_class = @task_response.school_class
    @assessment_task = AssessmentTask.find(@task_response.task)
    @activity_page = @assessment_task.activity_page
    @module_page = @activity_page.module_page
    @assessment_question_responses = @task_response.assessment_question_responses

    #for the dropdown
    @students = @school_class.students.not_teststudents.includes(:task_responses).where(:task_responses => {:task_id => @assessment_task, :school_class_id => @school_class}).order('last_name')
    if current_student
      @students << current_student if current_student.task_responses.find_by(task: @assessment_task, school_class: @school_class)
    end
    @responses_map = @students.map { |s|
      s.task_responses.find_by(task: @assessment_task, school_class: @school_class).id
    }
  end

  def index
    if params['task'].present?
      authorize! :read, @task = Task.find(params['task'])
      @school_classes = SchoolClass.accessible_by(@current_ability).order('name')
      @task_responses = @task_responses.where(task: @task)
      @response_map = @school_classes.map { |sc|
        #show only my students and my test student
        students = sc.students.not_teststudents << current_student
        {:name => sc.name, :responses => @task_responses.where(school_class: sc, student: students).map { |tr|
          {:student_first_name => tr.student.first_name,
           :student_last_name => tr.student.last_name,
           :response_id => tr.id}
        }.sort_by! { |hsh| hsh[:student_last_name] }}
      }
    else
      #Here it might instead be a good idea to create a page to
      #view all of the task responses visible to you?
      flash[:warning] = "You must specify a task to view the responses of."
      redirect_to root_path
    end
  end

  private
  def verify_assessment_task
    if params['task'].present?
      authorize! :read, @task = Task.find(params['task'])
      if @task.type != 'AssessmentTask'
        flash[:error] = "Only responses to question tasks can be viewed there."
        redirect_to root_path
      end
    end
  end

  def verify_assessment_task_response
    unless @task_response.is_a?(AssessmentTaskResponse)
      flash[:error] = "Only responses to question tasks can be viewed there."
      redirect_to root_path
    end
  end
end
