require 'spec_helper'

describe UnlocksController, type: :controller do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:task) { FactoryGirl.create(:assessment_task) }
  let(:unlock) { Unlock.create(student: student, school_class: school_class, unlockable: task) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  before do
    sign_in_as(super_staff)
  end

  describe 'Unlock' do
    describe 'when created' do
      before do
        school_class
        student
        task
        unlock
      end
      it 'should increment the count' do
        expect do
          xhr :post, :create, student_id: student.id, school_class_id: school_class.id, unlock:
              {unlockable: task, student: student, school_class: school_class, hidden: false}
        end.to change(Unlock, :count).by(1)
      end
      it 'should respond with OK' do
        xhr :post, :create, student_id: student.id, school_class_id: school_class.id, unlock:
            {unlockable: task, student: student, school_class: school_class, hidden: false}
        expect(response.status).to eq(200)
      end
    end

  end
end