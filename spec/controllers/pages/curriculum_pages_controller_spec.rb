require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::CurriculumPagesController, type: :controller do
  let(:controller_symbol) { :curriculum_page }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself) { FactoryGirl.create(:curriculum_page) }
  let(:myModel) { CurriculumPage }
  let(:my_children) { :module_page }

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

  it_behaves_like "a controller with children"

end