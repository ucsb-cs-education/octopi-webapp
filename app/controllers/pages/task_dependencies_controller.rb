class Pages::TaskDependenciesController < ApplicationController
  before_action :authenticate_staff!

  def create
    @prereq = Task.find(params[:task_dependency][:prerequisite_id])
    @dependant = Task.find(params[:assessment_task_id] || params[:laplaya_task_id] || params[:offline_task_id])
    @page = @dependant
    @dependency = @dependant.depend_on(@prereq)
    respond_to do |format|
      format.html { redirect_to @dependency }
      format.js do
        js false
      end
    end
  end

  def destroy
    @dependency = TaskDependency.find(params[:id])
    @dependency.destroy
    respond_to do |format|
      format.html { redirect_to @dependency }
      format.js do
        js false
      end
    end
  end

end
