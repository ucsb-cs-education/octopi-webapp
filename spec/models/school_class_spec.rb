require 'spec_helper'

describe SchoolClass, type: :model do

      before do
        @school_class = FactoryGirl.create(:school_class)
      end

      subject { @school_class }

      # Basic attributes
      it { should respond_to(:name) }
      it { should respond_to(:students) }
      it { should respond_to(:teachers) }

      it { should be_valid }

  describe 'when name is not present' do
    before { @school_class.name = ' ' }
    it { should_not be_valid }
  end

  describe '#teachers' do
    let(:teacher_in_the_school_class) { FactoryGirl.create(:staff, :teacher, school_class: @school_class) }
    let(:teacher_a_different_school_class) { FactoryGirl.create(:staff, :teacher, school_class: FactoryGirl.create(:school_class)) }
    it 'should contain teachers in the school class' do
      expect(@school_class.teachers.include?(teacher_in_the_school_class)).to be true
    end
    it 'should not contain teachers in a different school class' do
      expect(@school_class.teachers.include?(teacher_a_different_school_class)).to be false
    end

  end

  describe 'when name is already taken' do
    let(:school_class_with_same_name) { @school_class.dup }

    describe 'original school class' do
      it 'should be valid' do
        expect(@school_class).to be_valid
      end
    end

    describe 'duplicate school class' do
      it 'should not be valid' do
        expect(school_class_with_same_name).not_to be_valid
      end
    end
  end

  describe '#students' do
    let(:student_in_the_school_class) { FactoryGirl.create(:student, school_class: @school_class) }
    let(:student_in_a_different_school_class) { FactoryGirl.create(:student, school_class: FactoryGirl.create(:school_class)) }
    it 'should contain students in the school class' do
      expect(@school_class.students.include?(student_in_the_school_class)).to be true
    end
    it 'should not contain students in a different school class' do
      expect(@school_class.students.include?(student_in_a_different_school_class)).to be false
    end
  end

end

