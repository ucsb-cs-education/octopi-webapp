class Pages::TaskDependenciesController < ApplicationController
  before_action :authenticate_staff!

  def create
    #Task.find(params[:task_dependency][:dependant_id]).depend_on(Task.find(params[:task_dependency][:prerequisite_id]))
    @prereq = Task.find(params[:task_dependency][:prerequisite_id])
    @dependant = Task.find(params[:assessment_task_id] || params[:laplaya_task_id])
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
    @return = @dependency.prerequisite
    @dependency.destroy
    respond_to do |format|
      format.html { redirect_to @dependency }
      format.js do
        js false
      end
    end
  end

end
