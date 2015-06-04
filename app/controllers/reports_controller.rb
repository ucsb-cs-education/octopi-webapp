require 'json'

class ReportsController < ApplicationController
  before_action :authenticate_staff!
  before_action :set_report, only: [:show, :destroy, :create_run, :serve_code]
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
    @report = Report.where(id: params[:report_id]).first
    @report_run = ReportRun.where(report: @report, id: params[:report_run_id]).first
    rows = @report_run.report_run_results.joins(:laplaya_file).where(is_processed: true)
    if not rows.blank?
      @report_run_results = {rows: rows, cols: JSON.parse(rows.first.json_results).keys}
    else
      @report_run_results = {rows: [], cols: [] }
    end
    respond_to do |format|
      format.html # show_run.html.erb
      format.csv  { send_data render_run_as_csv(@report_run_results[:cols], rows) }
    end    
  end

  # GET /reports/1/code.js
  def serve_code 
    if params[:filename] == @report.code_filename
      send_data @report.code_contents
    else
      redirect_to @report
    end
    js false
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
    @report.code_filename = @orig.code_filename
    @report.code_contents = @orig.code_contents
    @report.description = @orig.description
    @report.name = 'Clone of ' + @orig.name
    @selected_classes = @orig.students.joins(:school_classes).pluck('school_class_id').uniq
    @selected_tasks = @orig.tasks.pluck(:id)
    @selected_sandboxes = @orig.report_module_options.where(include_sandbox: true).pluck(:module_page_id)
    @selected_projects = @orig.report_module_options.where(include_project: true).pluck(:module_page_id)
  end

  # POST /reports
  # POST /reports.json
  def create
    
    @report = Report.new(report_params) do |r|
      r.students = Student.where(id: SchoolClass.where(id: params[:selected_school_classes]).joins(:students).pluck(:student_id))
      r.tasks = LaplayaTask.where(id: params[:selected_tasks])
      if params[:report][:code_file_data]
        r.code_filename = params[:report][:code_file_data].original_filename
        r.code_contents = params[:report][:code_file_data].read
      end
    end
    @selected_classes = params[:selected_school_classes]
    @selected_tasks = params[:selected_tasks]
    @selected_sandboxes = params[:selected_sandboxes]
    @selected_projects = params[:selected_projects]

    @selected_classes ||= []
    @selected_tasks ||= []
    @selected_sandboxes ||= []
    @selected_projects ||= []

    @selected_sandboxes.each do |mid|
      mo = @report.report_module_options.where(module_page_id: mid)[0]
      if not mo
        mo = ReportModuleOptions.new(module_page_id: mid)
        @report.report_module_options << mo
      end
      mo.include_sandbox = true
      mo.save
    end


    @selected_projects.each do |mid|
      mo = @report.report_module_options.where(module_page_id: mid)[0]
      if not mo
        mo = ReportModuleOptions.new(module_page_id: mid)
        @report.report_module_options << mo
      end
      mo.include_project = true
      mo.save
    end


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
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      if params[:report_id]
        @report = Report.find(params[:report_id])
      else
        @report = Report.find(params[:id])
      end
    end

    def set_modules_and_schools
      @schools = School.all.order('name').select { |s| s.has_active_classes? }
      @module_pages = ModulePage.where(curriculum_id: 1).order('position ASC').select { |mp| mp.activity_pages.reduce(false) { |n, ap|  n |= ap.has_laplaya_tasks? } }
      if @report
        @selected_classes = @report.students.joins(:school_classes).pluck('school_class_id').uniq
        @selected_tasks = @report.tasks.pluck(:id)
        @selected_sandboxes = @report.report_module_options.where(include_sandbox: true).pluck(:module_page_id)
        @selected_projects = @report.report_module_options.where(include_project: true).pluck(:module_page_id)
      else
        @selected_classes = []
        @selected_tasks = []
        @selected_sandboxes = []
        @selected_projects = []
      end
      
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:name, :description)
    end

    def render_run_as_csv(cols, rows)
      CSV.generate do |csv|
        csv << ['Student ID', 'Classroom ID'].concat(cols)
        rows.each do |r|
          h = JSON.parse(r.json_results)
          values = [r.laplaya_file.user_id, r.laplaya_file.user.school_classes[0].id]
          values.concat(h.values_at(*cols))
          csv << values
        end
      end
    end
end
