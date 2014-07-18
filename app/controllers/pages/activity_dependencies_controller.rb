class Pages::ActivityDependenciesController < ApplicationController
  before_action :authenticate_staff!
  load_and_authorize_resource :activity_page

  def create
    @prereq = Task.find(params[:activity_dependency][:task_prerequisite_id])
    @dependant = @activity_page
    @dependant.depend_on(@prereq)
    respond_to do |format|
      format.html { redirect_to @prereq }
      format.js
    end
  end

  def destroy
    @dependency = ActivityDependency.find(params[:id])
    @return = @dependency.task_prerequisite
    @dependency.destroy
    redirect_to @return
  end

end
