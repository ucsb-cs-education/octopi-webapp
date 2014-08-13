ActiveAdmin.register Page do

  actions :all, except: [:new, :edit]
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
    @page = Page.find(params[:id])
    @versions = @page.versions
    render "layouts/history"
  end
  member_action :restore do
    @page = Page.find(params[:id])
    @page = @page.versions.find(params[:version].to_i).reify if params[:version]
    @page.save!
    redirect_to history_admin_page_path, notice: "File Restored!"
  end

  show :title=> :title do |page|
    attributes_table do
      row "Id" do
        page.id
      end
      [:designer_note, :type,:page_id, :curriculum_id, :teacher_body, :student_body, :created_at, :updated_at].each do |attribute|
        row attribute
      end
      row " " do
        link_to "versions", history_admin_page_path
      end
    end
  end

  controller do
    def show
      @page = Page.find(params[:id])
      @versions = @page.versions
      @page = @page.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
    end
  end
  sidebar :versionate, :partial => "layouts/version", :only => :show

end
