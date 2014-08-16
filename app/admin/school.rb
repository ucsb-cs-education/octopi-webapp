ActiveAdmin.register School do

  permit_params :name, :ip_range, :student_remote_access_allowed,curriculum_page_ids: []

  index do
    selectable_column
    id_column
    column :name
    actions
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

  form do |f|
    f.inputs "School details" do
      f.input :name
      #f.input :ip_range
      #f.input :student_remote_access_allowed
      f.input :curriculum_pages, as: :check_boxes, collection: CurriculumPage.all, label: 'Curricula' # Use formtastic to output my collection of checkboxes
    end
    f.actions
  end

  filter :curriculum_pages, label: 'Curricula'


end
