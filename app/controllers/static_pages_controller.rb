class StaticPagesController < ApplicationController
  def home
    #TODO: Do we want this? I thought it might be good to auto redirect to student login..
    # if not staff_signed_in?
    #   redirect_to student_portal_root_path
    # end
  end

  def help
  end
end
