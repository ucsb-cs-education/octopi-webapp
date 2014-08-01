class Pages::AssessmentQuestionsController < Pages::PagesController
  load_and_authorize_resource
  load_and_authorize_resource :assessment_task, only: [:new, :create]
  before_filter :set_page_variable
  js 'Pages/AssessmentQuestion'

  # GET /activity/:id
  def show
  end

  def update
    @assessment_question = AssessmentQuestion.find(params[:id])
    updated = @assessment_question.update(assessment_question_params)
    respond_to do |format|
      format.js do
        response.location = assessment_question_url(@assessment_question)
        js false
        unless updated
          head :bad_request, location: assessment_question_url(@assessment_question)
        end
      end
    end
  end

  def create
    begin
      AssessmentQuestion.transaction do
        @assessment_question.assessment_task = @assessment_task
        @assessment_question.save!
      end
    rescue ActiveRecord::RecordInvalid
      render text: @assessment_question.errors, status: :bad_request
      return
    end
    respond_to do |format|
      format.js {
        js false
        render status: :created
      }
    end
  end

  def destroy
    @assessment_question.destroy
    flash[:success] = "Question #{@assessment_question.title} has been deleted."
    redirect_to @assessment_question.assessment_task
  end

  def set_page_variable
    @page = @assessment_question if @assessment_question
    @pages = @assessment_questions if @assessment_questions
  end

  private
  def assessment_question_params
    params.require(:assessment_question).permit(:title, :question_body, :answers, :question_type)
  end

end
