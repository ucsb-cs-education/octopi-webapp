require 'spec_helper'

describe Staff, type: :model do

  describe 'basic staff' do

    before do
      @staff = FactoryGirl.create(:staff)
    end

    subject { @staff }

    # Basic attributes
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:encrypted_password) }
    #Non-database attributes
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }

    #Devise reset-password
    it { should respond_to(:reset_password_token) }
    it { should respond_to(:reset_password_sent_at) }

    #Devise rememberable
    it { should respond_to(:remember_created_at) }

    #Devise trackable
    it { should respond_to(:sign_in_count) }
    it { should respond_to(:current_sign_in_at) }
    it { should respond_to(:last_sign_in_at) }
    it { should respond_to(:current_sign_in_ip) }
    it { should respond_to(:last_sign_in_ip) }

    #Devise confirmable
    it { should respond_to(:confirmation_token) }
    it { should respond_to(:confirmed_at) }
    it { should respond_to(:confirmation_sent_at) }
    it { should respond_to(:unconfirmed_email) }

    it { should be_valid }

    describe '#name' do
      before do
        @staff.first_name = 'This is a strange'
        @staff.last_name = 'Name'
      end
      it 'returns the concatenated first and last name' do
        expect(@staff.name).to eq('This is a strange Name')
      end
    end

    describe 'when first_name is not present' do
      before { @staff.first_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when last_name is not present' do
      before { @staff.last_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when email is not present' do
      before { @staff.email = ' ' }
      it { should_not be_valid }
    end

    describe 'when first_name is too long' do
      before { @staff.first_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when last_name is too long' do
      before { @staff.last_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when email format is invalid' do
      it 'should be invalid' do
        addresses = %w[staff@foo,com staff_at_foo.org example.staff@foo. foo@bar..com
                     foo@bar_baz.com foo@bar+baz.com]
        addresses.each do |invalid_address|
          @staff.email = invalid_address
          expect(@staff).not_to be_valid
        end
      end
    end

    describe 'when email format is valid' do
      it 'should be valid' do
        addresses = %w[staff@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @staff.email = valid_address
          expect(@staff).to be_valid
        end
      end
    end

    describe 'when email address is already taken' do
      let(:staff_with_same_email) { @staff.dup }
      before do
        staff_with_same_email.email = @staff.email.upcase
        staff_with_same_email.save
      end

      describe 'original staff' do
        it 'should be valid' do
          expect(@staff).to be_valid
        end
      end

      describe 'duplicate staff' do
        it 'should be invalid' do
          expect(staff_with_same_email).not_to be_valid
        end
      end
    end

    describe 'when password is not present' do
      before do
        @staff.password = ' '
        @staff.password_confirmation = ' '
      end
      it { should_not be_valid }
    end

    describe 'when password doesn\'t match confirmation' do
      before { @staff.password_confirmation = 'mismatch' }
      it { should_not be_valid }
    end

    describe 'with a password that\'s too short' do
      before { @staff.password = @staff.password_confirmation = 'a' * 7 }
      it { should be_invalid }
    end

    describe 'return value of authenticate method' do
      before { @staff.save }
      let(:found_staff) { Staff.find_by(email: @staff.email) }

      describe 'with valid password' do
        it { should eq Staff.authenticate(@staff.email, @staff.password) }
      end

      describe 'with invalid password' do
        it { should_not eq Staff.authenticate(@staff.email, 'invalid') }
        specify { expect(Staff.authenticate(@staff.email, 'invalid')).to be_nil }
      end
    end

    describe 'email address with mixed case' do
      let(:mixed_case_email) { @staff.email = @staff.email.gsub(/./) { |c| [c, c.swapcase][rand(2)] }.gsub(/^./) { |c| c.upcase } }

      it 'should be saved as all lower-case' do
        @staff.email = mixed_case_email
        @staff.save
        expect(@staff.reload.email).to eq mixed_case_email.downcase
      end
    end

    it { should_not be_a_teacher }
    it { should_not be_a_school_admin }
    it { should_not be_a_super_staff }
  end

  describe 'school_admin' do

    before do
      @school_admin = FactoryGirl.create(:staff, :school_admin)
    end

    subject { @school_admin }

    it { should_not be_a_teacher }
    it { should be_a_school_admin }
    it { should_not be_a_super_staff }
    it 'shouldn\'t be a global :school_admin' do
      expect(@school_admin.has_role?(:school_admin)).to be false
      expect(@school_admin.has_role?(:school_admin, School)).to be false
    end

  end

  describe 'teacher' do

    before do
      @teacher = FactoryGirl.create(:staff, :teacher)
    end

    subject { @teacher }

    it { should be_a_teacher }
    it { should_not be_a_school_admin }
    it { should_not be_a_super_staff }
    it 'shouldn\'t be a global :teacher' do
      expect(@teacher.has_role?(:teacher)).to be false
      expect(@teacher.has_role?(:teacher, School)).to be false
    end

  end

end


