class StaticPagesController < ApplicationController
  def home
    if not user_signed_in?
      redirect_to student_portal_root_path
    end
  end

  def help
  end
end
