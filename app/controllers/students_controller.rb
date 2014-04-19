class StudentsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource
  before_action :check_school, only: [:edit, :show, :update, :destroy]

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


    def check_school
      if not @student.school.eql? @school
        raise CanCan::AccessDenied.new('Student does not belong to specified school', )
      end

    end

end
