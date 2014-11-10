ActiveAdmin.register Page do

  actions :all, except: [:new, :edit]
  filter :created_at
  filter :updated_at
  filter :type, as: :select, collection: %w(ActivityPage ModulePage CurriculumPage)

  index do
    selectable_column
    id_column
    column :type
    column :title
    column :created_at
    column :updated_at
  end

  member_action :history do
    @page = Page.find(params[:id])
    @versions = @page.versions
  end
  member_action :restore do
    @page = Page.find(params[:id])
    @resource = @page
    @version = @page.versions.find(params[:version])
    unless params[:recursive].nil?
      @page.restore_version(@version, params[:recursive] != 'false')
      redirect_to history_admin_page_path, notice: 'File Restored!'
    end
  end

  show :title => :title do |page|
    attributes_table do
      [:id, :type, :page_id, :teacher_body, :student_body, :designer_note, :created_at, :updated_at].each do |attribute|
        row attribute
      end
      row ' ' do
        link_to 'versions', history_admin_page_path
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
  sidebar :versionate, :partial => 'layouts/version', :only => :show

end
