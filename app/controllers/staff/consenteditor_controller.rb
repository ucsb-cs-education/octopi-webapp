class Staff::ConsenteditorController < ApplicationController
  def consenteditor
    authorize! :show,
               @filterrific = initialize_filterrific(
                   User,
                   params[:filterrific],
                   select_options: {
                       sorted_by: User.options_for_sorted_by,
                       with_school_id: School.options_for_select
                   }
               )or return
    @users = @filterrific.find.page(params[:page])
    respond_to do |format|
      format.html
      format.js {render :js => false}
    end
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end
end