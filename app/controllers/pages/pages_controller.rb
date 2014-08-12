class Pages::PagesController < ApplicationController
  before_action :authenticate_staff!
  js 'Pages/Pages'

  def save_version
    PaperTrail.whodunnit = user_for_paper_trail
    page = controller_name.classify.constantize.find(params[:id])
    page.save_current_version
    if controller_name == "assessment_tasks" || "module_pages" || "laplaya_tasks"
      page.save_children_versions
    end
    redirect_to :back
  end
end
