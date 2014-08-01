class Pages::ActivityDependenciesController < ApplicationController
  before_action :authenticate_staff!
  load_and_authorize_resource :activity_page

  def create
    @prereq = Task.find(params[:activity_dependency][:task_prerequisite_id])
    @dependant = ActivityPage.find(params[:activity_page_id])
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
    @dependency = ActivityDependency.find(params[:id])
    @dependency.destroy
    respond_to do |format|
      format.html { redirect_to @dependency }
      format.js do
        js false
      end
    end
  end

end
