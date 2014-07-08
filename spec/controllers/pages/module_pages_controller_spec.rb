require 'spec_helper'
require 'controllers/pages/shared_examples_for_page_controllers'

describe Pages::ModulePagesController , type: :controller do
  let(:controller_symbol) { :module_page }
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:myself){ FactoryGirl.create(:module_page)}
  let(:myModel){ModulePage}
  let(:parent_id_symbol){:curriculum_page_id}
  let(:myPath){module_page_url}

  before do
    sign_in_as_staff(super_staff)
  end

  describe "that should act like a page controller" do
    include_examples Pages::PagesController
  end

end