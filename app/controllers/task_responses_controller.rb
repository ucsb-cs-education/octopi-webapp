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
    if params['question'].present?
      @question_num = params['question']

      @question = AssessmentQuestion.find(@question_num)
      @task = @question.assessment_task
      @other_questions = @task.assessment_questions.where(assessment_question: nil)
      @activity = @task.activity_page
    else
      @curriculum_pages = CurriculumPage.accessible_by(@current_ability).order('title')
      @pages_map = @curriculum_pages.map { |cp|
        {:title => cp.title,
         :id => cp.id,
         :module_pages => cp.module_pages.map { |mp|
           {
               :activity_pages => mp.activity_pages.map { |ap|
                 {
                     :title => ap.title,
                     :assessment_tasks => ap.tasks.where(type: 'AssessmentTask').map { |at|
                       {
                           name: at.title,
                           question_id: at.assessment_questions.first.id
                       } if can? :view_responses, at
                     }.compact #remove nil
                 }
               }
           }
         }
        }
      }
    end
  end

  def gather_assessment_task_response_data
    js false;
    begin
      @assessment_task = AssessmentTask.find(params['task_id'])
      @assessment_task.assessment_questions.each { |aq|
        Resque.enqueue(BundleAssessmentTaskResponseData, aq.id) if aq.assessment_question.nil?
      }
      render :nothing => true, :status => :ok
    rescue Exception => e
      render js: "bootbox.alert('An error has occurred and the data is not being gathered. Please refresh and try again in a bit.')"
    end
  end

  def gather_assessment_question_response_data
    js false;
    begin
      Resque.enqueue(BundleAssessmentTaskResponseData, params['question_id'])
      render :nothing => true, :status => :ok
    rescue Exception => e
      render js: "bootbox.alert('An error has occurred and the data is not being gathered. Please refresh and try again in a bit.')"
    end
  end

  def download_csv_data
    js false;
    unless params['question_id'].nil?
      #if file exists send it
      file = "tmp/AssessmentQuestion_#{params['question_id']}_spreadsheet.xlsx"
      if File.exists?(file)
        @question = AssessmentQuestion.find(params['question_id'])
        send_file file, :filename => "#{@question.assessment_task.activity_page.title}_#{@question.assessment_task.title}_#{@question.title}_responses.xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      else
        flash[:warning]="The spreadsheet for this question does not appear to exist. Gathering the data again for this question may solve the problem."
        redirect_to :back
      end
    else
      flash[:warning] = "You must provide a question to download the spreadsheet of"
      redirect_to root_path
    end
  end

  private
  def verify_assessment_task
    if params['task'].present?
      authorize! :read, @task = Task.find(params['task'])
      authorize! :view_responses, @task unless @task.nil?
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
