class Pages::TaskDependenciesController < ApplicationController

  def delete
   @task = Task.find(params[:id])
   return
  end

end
