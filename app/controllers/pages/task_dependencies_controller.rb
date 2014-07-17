class Pages::TaskDependenciesController < ApplicationController
  before_action :signed_in_user

  def destroy
   @task = Task.find(params[:id])
  end

end
