require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::ActivityPagesController, type: :controller do
  let(:controller_symbol) { :activity_page }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:activity_page) }
  let(:myModel) { ActivityPage }
  let(:parent_id_symbol) { :module_page_id }
  let(:my_children) { :laplaya_task }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller that can create and destroy"
  it_behaves_like "a controller with children"

end