require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::LaplayaTasksController, type: :controller do
  let(:controller_symbol) { :laplaya_task }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself){ FactoryGirl.create(:laplaya_task)}
  let(:myModel){LaplayaTask}
  let(:parent_id_symbol){:activity_page_id}

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

end