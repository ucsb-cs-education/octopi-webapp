class StudentPortal::StudentsController < StudentPortal::BaseController
  before_action :signed_in_student

  def show
    @failed = false
  end

  def update
    @failed = !current_student.update_with_password(student_params)
    respond_to do |format|
      format.html do
        if @failed
          js :show
          flash[:error] = 'There was a problem updating your password'
          render 'show'
        else
          flash[:success] = 'Password successfully updated'
          redirect_to action: :show
        end
      end
    end
  end

  private
  def student_params
    params.require(:student).permit(:current_password, :password, :password_confirmation)
  end

end