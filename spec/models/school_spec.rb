require 'spec_helper'

describe School do

  before do
    @school = FactoryGirl.create(:school)
  end

  subject { @school }

  # Basic attributes
  it { should respond_to(:name) }
  it { should respond_to(:students) }
  it { should respond_to(:teachers) }
  it { should respond_to(:school_admins) }

  it { should be_valid }

  describe 'when name is not present' do
    before { @school.name = ' ' }
    it { should_not be_valid }
  end

  describe 'when name is too long' do
    before { @school.name = 'a' * 101 }
    it { should_not be_valid }
  end

  describe 'when name is already taken' do
    let(:school_with_same_name) { @school.dup }

    describe 'original school' do
      it 'should be valid' do
        expect(@school).to be_valid
      end
    end

    describe 'duplicate school' do
      it 'should not be valid' do
        expect(school_with_same_name).not_to be_valid
      end
    end
  end

  describe 'a school with the same name but different case' do
    let(:school_with_same_name) { @school.dup }
    before do
      school_with_same_name.name = school_with_same_name.name.upcase
    end

    describe 'original school' do
      it 'should be valid' do
        expect(@school).to be_valid
      end
    end

    describe 'duplicate school' do
      it 'should be valid' do
        expect(school_with_same_name).to be_valid
      end
    end
  end

  describe '#students' do
    let(:student_in_the_school) { FactoryGirl.create(:student, school: @school) }
    let(:student_in_a_different_school) { FactoryGirl.create(:student, school: FactoryGirl.create(:school)) }
    it 'should contain students in the school' do
      expect(@school.students.include?(student_in_the_school)).to be_true
    end
    it 'should not contain students in a different school' do
      expect(@school.students.include?(student_in_a_different_school)).to be_false
    end
  end

  describe '#teachers' do
    let(:teacher_in_the_school) { FactoryGirl.create(:user, :teacher, school: @school) }
    let(:teacher_a_different_school) { FactoryGirl.create(:user, :teacher, school: FactoryGirl.create(:school)) }
    it 'should contain teachers in the school' do
      expect(@school.teachers.include?(teacher_in_the_school)).to be_true
    end
    it 'should not contain teachers in a different school' do
      expect(@school.teachers.include?(teacher_a_different_school)).to be_false
    end
  end

  describe '#school_admins' do
    let(:school_admin_in_the_school) { FactoryGirl.create(:user, :school_admin, school: @school) }
    let(:school_admin_a_different_school) { FactoryGirl.create(:user, :school_admin, school: FactoryGirl.create(:school)) }
    let(:super_staff) { FactoryGirl.create(:user, :super_staff) }
    it 'should contain school_admins in the school' do
      expect(@school.school_admins.include?(school_admin_in_the_school)).to be_true
    end
    it 'should not contain school_admins in a different school' do
      expect(@school.school_admins.include?(school_admin_a_different_school)).to be_false
    end
    it 'should not contain super_staffs' do
      expect(@school.school_admins.include?(super_staff)).to be_false
    end
  end

end


