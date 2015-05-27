class Staff::ConsenteditorController < ApplicationController
  def consenteditor
    authorize! :show,
               @filterrific = initialize_filterrific(
                   Student,
                   params[:filterrific],
                   select_options: {
                       sorted_by: User.options_for_sorted_by,
                       with_school_id: School.options_for_select,
                       with_class_id: SchoolClass.options_for_select
                   }
               )or return
    @users = (@filterrific.find.page(params[:page]))
    @user = Student.new
    respond_to do |format|
      format.html
      format.js {render :js => false}
    end
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  def update_multiple
    @student = Student.new
    @students = params[:users]
    @students.each do |student|
      @student = Student.find((student[0].to_i))
      if (student[1]["has_consent"] == "1")
        @student.update_attribute(:has_consent,true)
      else
        @student.update_attribute(:has_consent, false)
      end
    end
    redirect_to("/staff/consenteditor", notice:"Updated!")
  end

end