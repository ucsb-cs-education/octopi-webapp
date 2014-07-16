require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::AssessmentTasksController, type: :controller do
  let(:controller_symbol) { :assessment_task }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:assessment_task) }
  let(:myModel) { AssessmentTask }
  let(:parent_id_symbol) { :activity_page_id }
  let(:my_children) { :assessment_question }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"
  it_behaves_like "a controller with children"
end