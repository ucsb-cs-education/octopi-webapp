ActiveAdmin.register LaplayaFile do
  actions :all, except: [:new, :edit]
  filter :versions
  filter :file_name
  filter :public
  filter :owner
  filter :created_at
  filter :updated_at


  index do
    selectable_column
    id_column
    column :file_name
    column :note
    column :public
    column :owner
    column :created_at
    column :updated_at
  end

  show do |file|

    attributes_table do
      row "File id" do
        file.id
      end
      [:file_name, :note, :public, :created_at, :updated_at].each do |attribute|
        row attribute
      end
    end
  end




end
