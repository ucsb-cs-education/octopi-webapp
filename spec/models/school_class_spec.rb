require 'spec_helper'

describe SchoolClass do
  require 'spec_helper'

  describe User do

    describe 'basic user' do

      before do
        @school_class = FactoryGirl.create(:school_class)
      end

      subject { @school_class }

      # Basic attributes
      it { should respond_to(:name) }

      it { should be_valid }


      describe 'when name is not present' do
        before { @user.name = ' ' }
        it { should_not be_valid }
      end

    end
  end
end
