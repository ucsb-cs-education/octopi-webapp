class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :destroy, :create_run]
  before_action :set_modules_and_schools, only: [:new, :create, :clone]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  def create_run
    @report.create_run
    redirect_to @report
  end

  # GET /reports/1/runs/15
  # GET /reports/1/runs/15.csv
  # GET /reports/1/runs/15.json
  def show_run 
    @run_results = ReportRunResults.where(report_run_id: params[:run_id]).joins(:report_runs).joins(:laplaya_files).joins(:user)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_runs }
      format.csv  { }
    end    
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @report_classes = SchoolClass.where(id: @report.students.joins(:school_classes).pluck('school_class_id'))
    @report_modules = ModulePage.where(id: [].concat(ActivityPage.where(id: @report.tasks.pluck(:page_id)).pluck(:page_id)).concat(@report.report_module_options.pluck(:module_page_id))).order(:position)
    @report_activities = ActivityPage.where(id: @report.tasks.pluck(:page_id)).joins(:module_page)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/clone
  def clone
    @orig = Report.find(params[:report_id])
    @report = Report.new
    @report.code = @orig.code
    @report.description = @orig.description
    @report.name = 'Clone of ' + @orig.name
    @selected_classes = @orig.students.joins(:school_classes).pluck('school_class_id').uniq
    @selected_tasks = @orig.tasks.pluck(:id)
  end

  # POST /reports
  # POST /reports.json
  def create
    
    @report = Report.new(report_params)
    @report.students = Student.where(id: SchoolClass.where(id: params[:selected_school_classes]).joins(:students).pluck(:student_id))
    @report.tasks = LaplayaTask.where(id: params[:selected_tasks])
    @selected_classes = params[:selected_school_classes]
    @selected_tasks = params[:selected_tasks]

    @selected_classes ||= []
    @selected_tasks ||= []

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render json: @report, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.code = nil
    @report.save
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    def set_modules_and_schools
      @schools = School.all.order('name').select { |s| s.has_active_classes? }
      @module_pages = ModulePage.where(curriculum_id: 1).order('position ASC').select { |mp| mp.activity_pages.reduce(false) { |n, ap|  n |= ap.has_laplaya_tasks? } }
      if @report
        @selected_classes = @report.students.joins(:school_classes).pluck('school_class_id').uniq
        @selected_tasks = @report.tasks.pluck(:id)
      else
        @selected_classes = []
        @selected_tasks = []
      end
      
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:name, :description, :code)
    end
end
