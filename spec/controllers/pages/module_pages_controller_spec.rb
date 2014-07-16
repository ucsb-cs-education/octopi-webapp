require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'
require 'controllers/pages/shared_examples_for_laplaya_cloning'

describe Pages::ModulePagesController, type: :controller do
  let(:controller_symbol) { :module_page }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:module_page) }
  let(:myModel) { ModulePage }
  let(:parent_id_symbol) { :curriculum_page_id }
  let(:my_children) { :activity_page }
  let(:curriculum_designer) { FactoryGirl.create(:staff, :curriculum_designer, curriclum_page: myself.curriculum_page) }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"
  it_behaves_like "a controller with children"
  describe "its project base file" do
    let(:laplaya_clone_action) { :clone_project }
    let(:laplaya_file_being_cloned_to) { myself.project_base_laplaya_file }
    let(:current_user) { super_staff }
    let(:my_path) { module_page_path(myself) }
    include_examples 'pages laplaya cloning'
  end
  describe "its sandbox base file" do
    let(:laplaya_clone_action) { :clone_sandbox }
    let(:laplaya_file_being_cloned_to) { myself.sandbox_base_laplaya_file }
    let(:current_user) { super_staff }
    let(:my_path) { module_page_path(myself) }
    include_examples 'pages laplaya cloning'
  end

  describe "creating a new module with ajax" do
    let(:module_page) { FactoryGirl.create(:module_page, curriculum_id: myself.curriculum_page.id ) }
    it "should increment the ProjectBaseLaplayaFile count" do
      module_page #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create,
            curriculum_page_id: module_page.parent.id,
            module_page: {
                title: module_page.title,
                teacher_body: module_page.teacher_body,
                student_body: module_page.student_body
            }
      end.to change(ProjectBaseLaplayaFile, :count).by(1)
    end
    it "should increment the SandboxBaseLaplayaFile count" do
      module_page #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create,
            curriculum_page_id: module_page.parent.id,
            module_page: {
                title: module_page.title,
                teacher_body: module_page.teacher_body,
                student_body: module_page.student_body
            }
      end.to change(SandboxBaseLaplayaFile, :count).by(1)
    end
  end

end