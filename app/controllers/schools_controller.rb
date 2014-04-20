class SchoolsController < ApplicationController
  after_action :set_school_cookie, only: [:show, :edit, :update]
  load_and_authorize_resource

  # GET /schools
  def index
    #Grab the school_id from the signed cookies
    redirect_school = School.find_by(:id => params[:school][:id]) if params[:school]
    authorize! :show, redirect_school if redirect_school
    redirect_school ||= School.find_by(:id => cookies.permanent.signed[:admin_last_school])
    #Check if the current user is authorized to view that school
    begin
      authorize! :show, redirect_school
    rescue CanCan::AccessDenied
      #If not, catch the exception and set the redirect_school to nil
      redirect_school = nil
    end
    #If redirect_school is not nil, grab the first accesible school for the user
    redirect_school ||= School.accessible_by(current_ability, :show).first
    #If the user has any accessible schools, go there. Otherwise, throw an access error
    if redirect_school != nil
      redirect_to redirect_school
    else
      raise CanCan::AccessDenied.new('You are not authorized to access this page.')
    end
  end

  # GET /schools/1
  def show

  end

  # GET /schools/new
  def new
    @school = School.new
  end

  # GET /schools/1/edit
  def edit
    render(:layout => 'layouts/devise')
  end

  # POST /schools
  def create
    @school = School.new(school_params)

    if @school.save
      redirect_to @school, notice: 'School was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /schools/1
  def update
    if @school.update(school_params)
      redirect_to @school, notice: 'School was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /schools/1
  def destroy
    @school.destroy
    redirect_to schools_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_school_cookie
    if @school != nil
      cookies.permanent.signed[:admin_last_school] = @school.id
    end
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def school_params
    #Only global_admins should be able to change the name of a school
    if can? :change_school_name, @school
      params.require(:school).permit(:name, :ip_range, :student_remote_access_allowed)
    else
      params.require(:school).permit(:ip_range, :student_remote_access_allowed)
    end
  end

end
