ActiveAdmin.register LaplayaFile do
  actions :all, except: [:new, :edit]
  filter :versions
  filter :file_name
  filter :public
  filter :owner
  filter :type, as: :select
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :file_name
    column :note
    column :type
    column :public
    column :owner
    column :created_at
    column :updated_at
  end
  member_action :history do
    @laplaya_file = LaplayaFile.find(params[:id])
    @versions = @laplaya_file.versions
    render "layouts/history"
  end
  member_action :restore do
    @laplaya_file = LaplayaFile.find(params[:id])
    @laplaya_file = @laplaya_file.versions.find(params[:version].to_i).reify if params[:version]
    @laplaya_file.save!
    redirect_to history_admin_laplaya_file_path, notice: "File Restored!"
  end
  show :title => :file_name do |file|

    attributes_table do
      row "File id" do
        file.id
      end
      [:note, :public, :created_at, :updated_at].each do |attribute|
        row attribute
      end
      row " " do
       link_to "versions", history_admin_laplaya_file_path
      end
    end
  end
  controller do
    def show
      @laplaya_file = LaplayaFile.find(params[:id])
      @versions = @laplaya_file.versions
      @laplaya_file = @laplaya_file.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
    end
  end
  sidebar :versionate, :partial => "layouts/version", :only => :show

end
