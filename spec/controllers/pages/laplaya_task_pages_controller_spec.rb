require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'
require 'controllers/pages/shared_examples_for_laplaya_cloning'

describe Pages::LaplayaTasksController, type: :controller do
  let(:controller_symbol) { :laplaya_task }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:laplaya_task) }
  let(:myModel) { LaplayaTask }
  let(:parent_id_symbol) { :activity_page_id }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"

  describe "its base file" do
    let(:laplaya_clone_action) { :clone }
    let(:laplaya_file_being_cloned_to) { myself.task_base_laplaya_file }
    let(:current_user) { super_staff }
    let(:my_path) { laplaya_task_url(myself) }
    include_examples 'pages laplaya cloning'
  end

end