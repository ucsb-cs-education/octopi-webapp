ActiveAdmin.register Task do

  actions :all, except: [:new, :edit]
  filter :activity_page
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :title
    column :created_at
    column :updated_at
  end

  member_action :history do
    @task = Task.find(params[:id])
    @versions = @task.versions
    render "layouts/history"
  end
  member_action :restore do
    @task = Task.find(params[:id])
    @task = @task.versions.find(params[:version].to_i).reify if params[:version]
    @task.save!
    redirect_to history_admin_task_path, notice: "File Restored!"
  end

  show  do |page|
    attributes_table do
      row "Id" do
        page.id
      end
      [:type, :teacher_body, :student_body, :created_at, :updated_at, :curriculum_id, :designer_note, :position, :page_id].each do |attribute|
        row attribute
      end
      row " " do
        link_to "versions", history_admin_task_path
      end
    end
  end

  controller do
    def show
      @task = Task.find(params[:id])
      @versions = @task.versions
      @task = @task.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
    end
  end
  sidebar :versionate, :partial => "layouts/version", :only => :show



end
