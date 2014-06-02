require 'spec_helper'

describe Staff do

  describe 'basic user' do

    before do
      @user = FactoryGirl.create(:user)
    end

    subject { @user }

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
        @user.first_name = 'This is a strange'
        @user.last_name = 'Name'
      end
      it 'returns the concatenated first and last name' do
        expect(@user.name).to eq('This is a strange Name')
      end
    end

    describe 'when first_name is not present' do
      before { @user.first_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when last_name is not present' do
      before { @user.last_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when email is not present' do
      before { @user.email = ' ' }
      it { should_not be_valid }
    end

    describe 'when first_name is too long' do
      before { @user.first_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when last_name is too long' do
      before { @user.last_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when email format is invalid' do
      it 'should be invalid' do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar..com
                     foo@bar_baz.com foo@bar+baz.com]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end

    describe 'when email format is valid' do
      it 'should be valid' do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end

    describe 'when email address is already taken' do
      let(:user_with_same_email) { @user.dup }
      before do
        user_with_same_email.email = @user.email.upcase
        user_with_same_email.save
      end

      describe 'original user' do
        it 'should be valid' do
          expect(@user).to be_valid
        end
      end

      describe 'duplicate user' do
        it 'should be invalid' do
          expect(user_with_same_email).not_to be_valid
        end
      end
    end

    describe 'when password is not present' do
      before do
        @user.password = ' '
        @user.password_confirmation = ' '
      end
      it { should_not be_valid }
    end

    describe 'when password doesn\'t match confirmation' do
      before { @user.password_confirmation = 'mismatch' }
      it { should_not be_valid }
    end

    describe 'with a password that\'s too short' do
      before { @user.password = @user.password_confirmation = 'a' * 7 }
      it { should be_invalid }
    end

    describe 'return value of authenticate method' do
      before { @user.save }
      let(:found_user) { Staff.find_by(email: @user.email) }

      describe 'with valid password' do
        it { should eq Staff.authenticate(@user.email, @user.password) }
      end

      describe 'with invalid password' do
        it { should_not eq Staff.authenticate(@user.email, 'invalid') }
        specify { expect(Staff.authenticate(@user.email, 'invalid')).to be_nil }
      end
    end

    describe 'email address with mixed case' do
      let(:mixed_case_email) { @user.email = @user.email.gsub(/./) { |c| [c, c.swapcase][rand(2)] }.gsub(/^./) { |c| c.upcase } }

      it 'should be saved as all lower-case' do
        @user.email = mixed_case_email
        @user.save
        expect(@user.reload.email).to eq mixed_case_email.downcase
      end
    end

    it { should_not be_a_teacher }
    it { should_not be_a_school_admin }
    it { should_not be_a_super_staff }
  end

  describe 'school_admin' do

    before do
      @school_admin = FactoryGirl.create(:user, :school_admin)
    end

    subject { @school_admin }

    it { should_not be_a_teacher }
    it { should be_a_school_admin }
    it { should_not be_a_super_staff }
    it 'shouldn\'t be a global :school_admin' do
      expect(@school_admin.has_role?(:school_admin)).to be_false
      expect(@school_admin.has_role?(:school_admin, School)).to be_false
    end

  end

  describe 'teacher' do

    before do
      @teacher = FactoryGirl.create(:user, :teacher)
    end

    subject { @teacher }

    it { should be_a_teacher }
    it { should_not be_a_school_admin }
    it { should_not be_a_super_staff }
    it 'shouldn\'t be a global :teacher' do
      expect(@teacher.has_role?(:teacher)).to be_false
      expect(@teacher.has_role?(:teacher, School)).to be_false
    end

  end

end


