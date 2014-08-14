require 'spec_helper'

describe ActivityUnlocksController, type: :controller do
  let(:school_class) { FactoryGirl.create(:school_class) }
  let(:student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
  let(:activity) { FactoryGirl.create(:activity_page) }
  let(:unlock) { ActivityUnlock.create(student: student, school_class: school_class, activity_page: activity) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  before do
    sign_in_as(super_staff)
  end

  describe "An Activity Unlock" do
    describe "when created" do
      before do
        school_class
        student
        activity
        unlock
      end
      it "should not increment the count" do
        expect do
          xhr :post, :create, student_id: student.id, school_class_id: school_class.id, activity_unlock:
              {activity_page_id: activity, student_id: student, school_class: school_class, hidden: false}
        end.to_not change(ActivityUnlock, :count)
      end
      it "should increment the count of unlocked Activity Unlocks" do
        expect do
          xhr :post, :create, student_id: student.id, school_class_id: school_class.id, activity_unlock:
              {activity_page_id: activity, student_id: student, school_class: school_class, hidden: false}
        end.to change(ActivityUnlock.unlocked, :count).by(1)
      end
      it "should respond with OK" do
        xhr :post, :create, student_id: student.id, school_class_id: school_class.id, activity_unlock:
            {activity_page_id: activity, student_id: student, school_class: school_class, hidden: false}
        expect(response.status).to eq(200)
      end
    end

  end
end