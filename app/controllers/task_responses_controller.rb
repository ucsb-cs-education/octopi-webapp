class TaskResponsesController < ApplicationController
  load_and_authorize_resource :task_response
  before_action :verify_assessment_task_response, only: [:show]
  before_action :verify_assessment_task, only: [:index]
  before_action :make_no_cache

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
      @assessment_task_array = @assessment_task.assessment_questions.to_a
      Resque.enqueue(BundleAssessmentTaskResponseData, @assessment_task_array.shift.id, true)
      @assessment_task_array.each { |aq|
        Resque.enqueue(BundleAssessmentTaskResponseData, aq.id, false) if aq.assessment_question.nil?
      }
      render :nothing => true, :status => :ok
    rescue Exception => e
      render js: "bootbox.alert('An error has occurred and the data is not being gathered. Please refresh and try again in a bit.')"
    end
  end

  def gather_assessment_question_response_data
    if AssessmentQuestion.find(params['question_id']).assessment_question == nil
      js false;
      begin
        Resque.enqueue(BundleAssessmentTaskResponseData, params['question_id'], true)
        render :nothing => true, :status => :ok
      rescue Exception => e
        render js: "bootbox.alert('An error has occurred and the data is not being gathered. Please refresh and try again in a bit.')"
      end
    else
      render js: "bootbox.alert('Do not generate data for a variant.')"
    end
  end

  def download_csv_data
    js false;
    unless params['task_id'].nil?
      #if file exists send it
      file = "tmp/AssessmentTask_#{params['task_id']}_spreadsheet.xlsx"
      if File.exists?(file)
        @task = AssessmentTask.find(params['task_id'])
        send_file file, :filename => "#{@task.activity_page.title}_#{@task.title}_responses.xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      else
        flash[:warning]='The spreadsheet for this task does not appear to exist. If this data was recently generated
                        it is possible the page was completed before the spreadsheet. Please refresh and try again.
                        Regenerate the data for this page if the problem persists.'
        redirect_to :back
      end
    else
      flash[:warning] = "You must provide a task to download the spreadsheet of"
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

  def make_no_cache
    #This doesnt actually seem to work?
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
