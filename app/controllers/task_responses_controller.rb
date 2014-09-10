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
      # THIS MAY BE COMPLETELY OBSELETE?
      authorize! :read, @task = Task.find(params['task'])
      @school_classes = SchoolClass.accessible_by(@current_ability).order('name')
      @task_responses = @task_responses.where(task: @task)
      @response_map = @school_classes.map { |sc|
        #show only my students and my test student
        students = sc.students.not_teststudents << current_student
        {:name => sc.name, :id => sc.id, :responses => @task_responses.where(school_class: sc, student: students).map { |tr|
          {:student_first_name => tr.student.first_name,
           :student_last_name => tr.student.last_name,
           :response_id => tr.id}
        }.sort_by! { |hsh| hsh[:student_last_name] }}
      }
    elsif params['question'].present?
      @question = AssessmentQuestion.find(params['question'])
      @task = @question.assessment_task
      @other_questions = @task.assessment_questions.where(assessment_question: nil)
      @activity = @task.activity_page
      @questions = (AssessmentQuestion.where(assessment_question: @question) << @question).rotate(-1) #bring the first variant back to front
      @responses = AssessmentQuestionResponse.includes(:task_response).where(assessment_question: @questions)

      @charts = []
      #lets make a-da chart!
     # case @question.question_type
      #  when "singleAnswer"
       #   @questions.each{|q|
        #    @charts.push(
        #
        #    )
        #  }
        #when "multipleAnswers"
      #end
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
                           id: at.id
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

  def download_csv_data
    #when all else is finished, this will become a simple action that sends a preexisting file
    #the actual generation will occur in resque workers
    #perhaps when you tell it to recalculate, it will ask if it should send you an email with the csv once it has completed?
    unless params['question_id'].nil?
      @question = AssessmentQuestion.find(params['question_id'])
      @task = @question.assessment_task
      @other_questions = @task.assessment_questions.where(assessment_question: nil)
      @activity = @task.activity_page
      @questions = (AssessmentQuestion.where(assessment_question: @question) << @question).rotate(-1) #bring the first variant back to front
      @responses = AssessmentQuestionResponse.includes(:task_response).where(assessment_question: @questions)

      response_book = Axlsx::Package.new
      wb = response_book.workbook

      @questions.each { |q|
        unless (type = q.question_type)=="freeResponse"
          correct_answer = ""
          JSON.parse(q.answers).each_with_index { |a, i|
            if a['correct']==true
              correct_answer+=(i+1).to_s+" "
            end
          }
        end
        wb.add_worksheet(:name => q.title) do |sheet|
          sheet.add_row ["School", "Class", "Student Number", (type=="freeResponse" ? "Response" : "Correct Response: #{correct_answer}")]
          @responses.where(assessment_question: q).each { |response|
            unless type=="freeResponse"
              ans_array=[]
              JSON.parse(response.selected).each { |r|
                ans_array.push(r+1)
              }
            else
              ans_array=[0]
            end
            ans_array.each { |x|
              sheet.add_row [response.task_response.student.school.name,
                             response.task_response.school_class.name,
                             response.task_response.student.id.to_s,
                             (type=="freeResponse" ? response.selected : x.to_s)]
            }
          }
        end
      }
      js false;
      output = StringIO.new
      response_book.use_shared_strings = true
      output.write(response_book.to_stream.read)
      send_data output.string, filename: "#{@question.title}_student_responses.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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
