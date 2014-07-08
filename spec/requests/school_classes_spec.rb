require 'spec_helper'

describe "SchoolClasses" do
  describe "GET /school_classes" do
    let(:staff){FactoryGirl.create(:staff,:super_staff)}
    let(:school_class){FactoryGirl.create(:school_class)}
    subject {page}
    describe 'valid page' do
      before do
        sign_in_as_a_valid_staff(staff)
        visit school_class_path(school_class)
      end
      it { should have_content('Help') }
    end

  end
end
