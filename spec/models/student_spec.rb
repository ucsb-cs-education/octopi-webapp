require 'spec_helper'

describe Student, type: :model do

    before do
      @student = FactoryGirl.create(:student)
    end

    subject { @student }

    # Basic attributes
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:login_name) }
    it { should respond_to(:password_digest) }
    #Non-database attributes
    it { should respond_to(:name) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }

    it { should respond_to(:school) }

    it { should be_valid }

    describe '#name' do
      before do
        @student.first_name = 'This is a strange'
        @student.last_name = 'Name'
      end
      it 'returns the concatenated first and last name' do
        expect(@student.name).to eq('This is a strange Name')
      end
    end

    describe 'when first_name is not present' do
      before { @student.first_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when last_name is not present' do
      before { @student.last_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when first_name is too long' do
      before { @student.first_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when last_name is too long' do
      before { @student.last_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when login_name is not present' do
      before { @student.login_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when login_name is too long' do
      before { @student.login_name = 'a' * 51 }
      it { should_not be_valid }
    end

    describe 'when login_name is already taken' do
      let(:student_with_same_login_name) { @student.dup }
      let(:student_with_same_login_name_but_different_school) { @student.dup }
      before do
        student_with_same_login_name.login_name = @student.login_name.upcase
        student_with_same_login_name.save
        student_with_same_login_name_but_different_school.school = FactoryGirl.create(:school)
        student_with_same_login_name_but_different_school.save
      end

      describe 'original student' do
        it 'should be valid' do
          expect(@student).to be_valid
        end
      end

      describe 'student with same login_name but at a different school' do
        it 'should be valid' do
          expect(student_with_same_login_name_but_different_school).to be_valid
        end
      end

      describe 'student with same login_name at same school' do
        it 'should be invalid' do
          expect(student_with_same_login_name).not_to be_valid
        end
      end
    end

    describe 'when password is not present' do
      before do
        @student.password = ' '
        @student.password_confirmation = ' '
      end
      it { should_not be_valid }
    end

    describe 'when school_id is not present' do
      before do
        @student.school_id = nil
      end
      it { should_not be_valid }
    end

    describe 'when school_id doesn\'t represent an actual school' do
      before do
        magic_number = 1234567
        assert (School.find_by(:id => magic_number ) == nil )
        @student.school_id = magic_number
      end
      it { should_not be_valid }
    end

    describe 'when password doesn\'t match confirmation' do
      before { @student.password_confirmation = 'mismatch' }
      it { should_not be_valid }
    end

    describe 'return value of authenticate method' do
      before { @student.save }
      let(:found_student) { Student.find_by(:school_id => @student.school_id, :login_name => @student.login_name) }

      describe 'with valid password' do
        it { should eq found_student.authenticate(@student.password) }
      end

      describe 'with invalid password' do
        it { should_not eq found_student.authenticate('invalid') }
        specify { expect(found_student.authenticate('invalid')).to be false }
      end
    end
end


