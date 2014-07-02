class Pages::TasksController < Pages::PagesController

  load_and_authorize_resource
  load_and_authorize_resource :activity_page, only: [:new, :create]
  before_filter :set_page_variable

  # GET /activity/:id
   def show
   end

   def create
      @task.parent = @activity_page
     @task.update_attributes({title: 'New Task', teacher_body: '<p></p>', student_body: '<p></p>'})
     respond_to do |format|
       format.html { redirect_to @activity_page }
        format.js {
         js false
       }
     end
   end

   def destroy
     @task.destroy
     flash[:success] = "Task #{@task.title} has been deleted."
     redirect_to @task.activity_page
   end

  def set_page_variable
    @page = @task.becomes(Task) if @task
    @pages = @tasks.map{|x| x.becomes(Task)} if @tasks
  end

end
