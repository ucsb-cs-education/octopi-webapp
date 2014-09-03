ActiveAdmin.register School do

  permit_params :name, :ip_range, :student_remote_access_allowed,curriculum_page_ids: []

  index do
    selectable_column
    id_column
    column :name
    actions
    session[:admin_school_back_url] = request.original_url || school_path(resource)
  end

  action_item :only=> :show do
    link_to 'Back', session[:admin_school_back_url]
  end

  show :title => :name do
    attributes_table :name do
      table_for school.school_classes.order('name ASC') do
        column 'Classes' do |school_class|
          link_to school_class.name, [:admin, school_class]
        end
      end
      table_for school.curriculum_pages.order('title ASC') do
        column 'Curricula' do |curriculum|
          link_to curriculum.title, curriculum
        end
      end

    end
  end

  form partial: 'form'

  filter :curriculum_pages, label: 'Curricula'


end
