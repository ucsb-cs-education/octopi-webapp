class SchoolClassesController < ApplicationController
  before_action :set_school_class, only: [:show, :edit, :update, :destroy]

  # GET /schools
  # GET /schools.json
  def index
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_school_class
    @school_class = SchoolClass.find(params[:id])
  end

end
