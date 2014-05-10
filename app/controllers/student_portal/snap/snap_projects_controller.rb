class SnapProjectsController < ApplicationController
  before_action :set_snap_project, only: [:show, :edit, :update, :destroy]

  # GET /snap_projects
  def index
    @snap_projects = SnapProject.all
  end

  # GET /snap_projects/1
  def show
  end

  # GET /snap_projects/new
  def new
    @snap_project = SnapProject.new
  end

  # GET /snap_projects/1/edit
  def edit
  end

  # POST /snap_projects
  def create
    @snap_project = SnapProject.new(snap_project_params)

    if @snap_project.save
      redirect_to @snap_project, notice: 'Snap project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /snap_projects/1
  def update
    if @snap_project.update(snap_project_params)
      redirect_to @snap_project, notice: 'Snap project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /snap_projects/1
  def destroy
    @snap_project.destroy
    redirect_to snap_projects_url, notice: 'Snap project was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snap_project
      @snap_project = SnapProject.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def snap_project_params
      params.require(:snap_project).permit(:projectName, :public)
    end
end
