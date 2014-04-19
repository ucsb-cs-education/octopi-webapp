class StudentsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource
  before_filter :load_school

  def index
    @students = @school.students
  end

  def new
    render(:layout => 'layouts/devise')
    @student = Student.new
  end

  def show

  end

  # DELETE /schools/1
  def destroy
    $stderr.puts "@@@@@@@@@@@@@@@#{@student.name}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    @student.destroy
    respond_to do |format|
      format.html { redirect_to school_students_path(@school.id) }
    end
  end

  def create
    @student = Student.new(student_params)
    @student.school = @school
    #Might need to add School.with_role(:school_admin, current_user).pluck(:id).includes(@student.school_id) && , lets chcek
    if @student.save
      flash[:success] = 'Student saved successfully.'
      redirect_to school_students_path
    else
      render 'new', :layout => 'layouts/devise'
      $stderr.puts @student.errors.messages
    end
  end

  private
    def student_params
      params.require(:student).permit(:name, :login_name, :password, :password_confirmation)
    end

    def load_school
      @school = School.find(params[:school_id])
    end

end
