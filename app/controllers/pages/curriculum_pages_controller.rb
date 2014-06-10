class Pages::CurriculumPagesController < Pages::PagesController
  load_and_authorize_resource
  before_filter :set_page_variable

  # GET /schools
  def index
    #Grab the curriculum_pages_id from the signed cookies
    redirect_curriculum = CurriculumPage.find_by(:id => params[:curriculum_page][:id]) if params[:curriculum_pagel]
    authorize! :show, redirect_curriculum if redirect_curriculum
    redirect_curriculum ||= CurriculumPage.find_by(:id => cookies.permanent.signed[:admin_last_curriculum])
    #Check if the current user is authorized to view that school
    begin
      authorize! :show, redirect_curriculum
    rescue CanCan::AccessDenied
      #If not, catch the exception and set the redirect_school to nil
      redirect_curriculum = nil
    end
    #If redirect_school is not nil, grab the first accesible school for the user
    redirect_curriculum ||= CurriculumPage.accessible_by(current_ability, :show).first
    #If the user has any accessible schools, go there. Otherwise, throw an access error
    if redirect_curriculum != nil
      redirect_to redirect_curriculum
    else
      raise CanCan::AccessDenied.new('You are not authorized to access this page.')
    end
  end

  # GET /curriculums/:id
  def show
  end

  def sort
    @curriculum_page.update_children_order(params[:module_page])
    render nothing: true
  end

  def update
    updated = @curriculum_page.update_attributes(curriculum_params)
    respond_to do |format|
      format.html do
        if updated
          redirect_to @curriculum_page, notice: "Successfully updated"
        else
          render action: edit
        end
      end
      format.js do
        if updated
          status = :no_content
        else
          status = :bad_request
        end
        head status, location: curriculum_page_url(@curriculum_page)
      end
    end
  end

  private
  def set_page_variable
    @page = @curriculum_page
    @pages = @curriculum_pages
  end

  def curriculum_params
    params.require(:curriculum_page).permit(:title, :'teacher_body', :'student_body')
  end


end
