class TimeIntervalsController < ApplicationController
  respond_to :json

  def create
    if @interval = TaskResponse.find(params[:task_response_id]).make_new_interval(params[:begin_time])
      respond_to do |format|
        format.json do
          render json: @interval
        end
      end
    else
      #ignore?
    end
  end

  def update
    @interval = TimeInterval.find(params[:id])
    if @interval.update!(time_interval_params)
      respond_to do |format|
        format.json do
          render json: @interval
        end
      end
    else
      #ignore?
    end
  end

  private
  def time_interval_params
    params.permit(:begin_time, :end_time, :task_response_id)
  end
end