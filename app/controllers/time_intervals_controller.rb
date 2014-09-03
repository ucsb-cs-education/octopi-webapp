class TimeIntervalsController < ApplicationController
  respond_to :json

  def create
    if @interval = TaskResponse.find(params[:task_response_id]).make_new_interval()
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
    if @interval.update!(end_time: Time.new.to_i)
      respond_to do |format|
        format.json do
          render json: @interval
        end
      end
    else
      #ignore?
    end
  end

  def complete
    @interval = TimeInterval.find(params[:id])
    endtime = Time.new.to_i
    if @interval.update!(end_time: endtime)
      @interval.complete
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
    params.permit(:task_response_id)
  end
end