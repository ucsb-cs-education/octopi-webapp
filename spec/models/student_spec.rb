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
      assert (School.find_by(:id => magic_number) == nil)
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

  describe "when an action affecting their unlocks and responses has happened" do
    let(:school_class_1) { FactoryGirl.create(:school_class) }
    let(:school_class_2) { FactoryGirl.create(:school_class) }
    let(:task_1) { FactoryGirl.create(:laplaya_task) }
    let(:task_2) { FactoryGirl.create(:assessment_task) }
    let(:task_3) { FactoryGirl.create(:assessment_task) }
    let(:unlock_1) { Unlock.create(school_class: school_class_1, unlockable: task_1, student: @student) }
    let(:unlock_2) { Unlock.create(school_class: school_class_1, unlockable: task_2, student: @student) }
    let(:unlock_3) { Unlock.create(school_class: @student.school_classes.first, unlockable: task_2, student: @student) }
    let(:unlock_4) { Unlock.create(school_class: school_class_1, unlockable: task_3, student: @student) }
    let(:response_1) { TaskResponse.create(student: @student, school_class: school_class_1, task: task_1, completed: true) }
    let(:response_2) { AssessmentTaskResponse.create(student: @student, school_class: school_class_1, task: task_2) }
    let(:response_3) { TaskResponse.create(student: @student, school_class: @student.school_classes.first, task: task_2) }
    let(:assessment_question_response) { AssessmentQuestionResponse.create(task_response: response_2) }

    before do
      school_class_1
      school_class_2
      task_1
      task_2
      task_3
      task_1.activity_page.tasks << task_2
      task_1.activity_page.tasks << task_3
      school_class_1.module_pages << task_1.activity_page.module_page
      task_2.depend_on(task_1)
      task_3.depend_on(task_2)
      unlock_1
      unlock_2
      unlock_3
      unlock_4
      Unlock.create(school_class: school_class_1, unlockable: task_1.activity_page, student: @student)
      response_1
      response_2
      assessment_question_response
      response_3
      @student.task_responses << response_1
      @student.task_responses << response_2
      @student.task_responses << response_3
      @student.school_classes << school_class_1
    end

    describe "after being moved from school_class_1 to school_class_2" do
      subject { lambda { @student.change_school_class(school_class_1, school_class_2, true) } }

      it { should change { TaskResponse.where(school_class: school_class_1).count }.by(-2) }
      it { should change { Unlock.where(school_class: school_class_1).count }.by(-4) }

      it { should change { TaskResponse.where(school_class: school_class_2).count }.by(2) }
      it { should change { Unlock.where(school_class: school_class_2).count }.by(4) }

      it { should_not change { TaskResponse.where(school_class: @student.school_classes.first).count } }
      it { should_not change { Unlock.where(school_class: @student.school_classes.first).count } }

      it { should_not change { SchoolClass.count } }
      it "should cause student to have school_class_2 and school_class_2 to have student" do
        @student.change_school_class(school_class_1, school_class_2, true)
        expect(@student.school_classes).to include(school_class_2)
        expect(school_class_2.students).to include(@student)
      end
      it "should cause student to not have school_class_1 and school_class_1 to not have student" do
        @student.change_school_class(school_class_1, school_class_2, true)
        expect(@student.school_classes).to_not include(school_class_1)
        expect(school_class_1.students).to_not include(@student)
      end

    end

    describe "after being moved from school_class_1 to school_class_2 with conflicts" do
      let(:response_conflict) { AssessmentTaskResponse.create(student: @student, school_class: school_class_2, task: task_2) }
      let(:unlock_conflict) { Unlock.create(school_class: school_class_2, unlockable: task_2, student: @student) }

      before do
        unlock_conflict
        response_conflict
      end

      describe "when delete_new__class_data_if_conflict is true" do
        subject { lambda { @student.change_school_class(school_class_1, school_class_2, true) } }

        it { should change { TaskResponse.where(school_class: school_class_1).count }.by(-2) }
        it { should change { Unlock.where(school_class: school_class_1).count }.by(-4) }

        #the unlock changes are by 2 here because by saving the new AssessmentTaskResponse, dependencies are unlocked and, making task 3 unlocked
        it { should change { Unlock.where(school_class: school_class_2).count }.by(2) }
        it { should change { Unlock.count }.by(-2) }

        it "should replace the conflicting unlock" do
          @student.change_school_class(school_class_1, school_class_2, true)
          expect(Unlock.find_by(school_class: school_class_2, unlockable: task_2, student: @student).id).to_not eq(unlock_conflict.id)
        end
        it "should replace the conflicting response" do
          @student.change_school_class(school_class_1, school_class_2, true)
          expect(TaskResponse.find_by(school_class: school_class_2, task: task_2, student: @student).id).to_not eq(response_conflict.id)
        end

        it "should not replace a non-conflicting unlock" do
          @student.change_school_class(school_class_1, school_class_2, true)
          expect(Unlock.find_by(school_class: school_class_2, unlockable: task_1, student: @student).id).to eq(unlock_1.id)
        end
        it "should not replace a non-conflicting response" do
          @student.change_school_class(school_class_1, school_class_2, true)
          expect(TaskResponse.find_by(school_class: school_class_2, task: task_1, student: @student).id).to eq(response_1.id)
        end

        it { should_not change { TaskResponse.where(school_class: @student.school_classes.first).count } }
        it { should_not change { Unlock.where(school_class: @student.school_classes.first).count } }
        it { should_not change { AssessmentQuestionResponse.count } }
      end
      describe "when delete_new__class_data_if_conflict is false" do
        subject { lambda { @student.change_school_class(school_class_1, school_class_2, false) } }

        it { should change { TaskResponse.where(school_class: school_class_1).count }.by(-2) }
        it { should change { Unlock.where(school_class: school_class_1).count }.by(-4) }

        #the unlock changes are by 2 here because by saving the new AssessmentTaskResponse, dependencies are unlocked, making task_3 is unlocked
        it { should change { TaskResponse.where(school_class: school_class_2).count }.by(1) }
        it { should change { Unlock.where(school_class: school_class_2).count }.by(2) }
        it { should change { Unlock.count }.by(-2) }

        it "should not replace the conflicting unlock" do
          @student.change_school_class(school_class_1, school_class_2, false)
          expect(Unlock.find_by(school_class: school_class_2, unlockable: task_2, student: @student).id).to eq(unlock_conflict.id)
        end
        it "should not replace the conflicting response" do
          @student.change_school_class(school_class_1, school_class_2, false)
          expect(TaskResponse.find_by(school_class: school_class_2, task: task_2, student: @student).id).to eq(response_conflict.id)
        end

        it "should not replace a non-conflicting unlock" do
          @student.change_school_class(school_class_1, school_class_2, false)
          expect(Unlock.find_by(school_class: school_class_2, unlockable: task_1, student: @student).id).to eq(unlock_1.id)
        end
        it "should not replace a non-conflicting response" do
          @student.change_school_class(school_class_1, school_class_2, false)
          expect(TaskResponse.find_by(school_class: school_class_2, task: task_1, student: @student).id).to eq(response_1.id)
        end

        it { should_not change { TaskResponse.where(school_class: @student.school_classes.first).count } }
        it { should_not change { Unlock.where(school_class: @student.school_classes.first).count } }
        it { should change { AssessmentQuestionResponse.count }.by(-1) }
      end
    end

    describe "after deleting all data for school_class_1" do
      subject { lambda { @student.delete_all_data_for(school_class_1) } }

      it { should change { TaskResponse.where(school_class: school_class_1).count }.by(-2) }
      it { should change { Unlock.where(school_class: school_class_1).count }.by(-4) }
      it { should change { AssessmentQuestionResponse.count }.by(-1) }

      it { should_not change { TaskResponse.where(school_class: school_class_2).count } }
      it { should_not change { Unlock.where(school_class: school_class_2).count } }

      it { should_not change { TaskResponse.where(school_class: @student.school_classes.first).count } }
      it { should_not change { Unlock.where(school_class: @student.school_classes.first).count } }

      it { should_not change { SchoolClass.count } }
      it "should cause student to no longer have school_class_1" do
        @student.delete_all_data_for(school_class_1)
        expect(@student.school_classes).to_not include(school_class_1)
      end
      it "should cause school_class_1 to no longer have student" do
        @student.delete_all_data_for(school_class_1)
        expect(school_class_1.students).to_not include(@student)
      end
    end

    describe "after deleting the student all dependants should be destroyed" do
      subject { lambda { @student.destroy } }
      it { should change { TaskResponse.count }.by(-3) }
      it { should change { Unlock.count }.by(-5) }
      it { should change { AssessmentQuestionResponse.count }.by(-1) }
    end

    describe 'after resetting the dependency graph for school_class_1' do
      subject { lambda { @student.reset_dependency_graph_for(school_class_1) } }

      describe "when there are tasks/activities that have been manually unlocked and the prerequisites are not met" do
        let(:manually_unlocked_task) { FactoryGirl.create(:laplaya_task) }
        let(:manual_unlock) { Unlock.create(school_class: school_class_1, unlockable: manually_unlocked_task, student: @student) }
        let(:manually_unlocked_activity) { FactoryGirl.create(:activity_page) }
        let(:manual_unlock_2) { Unlock.create(school_class: school_class_1, unlockable: manually_unlocked_activity, student: @student) }

        before do
          manually_unlocked_task
          manual_unlock
          manually_unlocked_activity.tasks << manually_unlocked_task
          task_1.activity_page.module_page.activity_pages << manually_unlocked_activity
          manually_unlocked_activity.depend_on(task_3)
          manually_unlocked_task.depend_on(task_3)
          manually_unlocked_activity.tasks << manually_unlocked_task
          manual_unlock_2
        end

        describe "when the student has not responded to a task in the activity" do
          it { should change { Unlock.count }.by(-2) }
          it { should change { TaskResponse.count }.by(0) }
          it "should remove the unlocks for tasks/activities with no response and not related to a dependency" do
            @student.reset_dependency_graph_for(school_class_1)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: manually_unlocked_task, student: @student)).to eq(nil)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: manually_unlocked_activity, student: @student)).to eq(nil)
          end
          it "should replace the original unlocks" do
            @student.reset_dependency_graph_for(school_class_1)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_1, student: @student).id).to_not eq(unlock_1.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_2, student: @student).id).to_not eq(unlock_2.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_3, student: @student).id).to_not eq(unlock_4.id)
          end
          it "should not replace unlocks in other school_classes" do
            @student.reset_dependency_graph_for(school_class_1)
            expect(Unlock.find_by(school_class: @student.school_classes.first, unlockable: task_2, student: @student).id).to eq(unlock_3.id)
          end
        end

        describe "when the student has responded to a task in the activity" do
          let(:student_response) { LaplayaTaskResponse.create(completed: false, student: @student, school_class: school_class_1, task: manually_unlocked_task) }

          before do
            student_response
            @student.task_responses << student_response
          end

          it { should_not change { Unlock.count } }
          it { should_not change { TaskResponse.count } }
          it "should replace the original unlocks" do
            @student.reset_dependency_graph_for(school_class_1)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_1, student: @student).id).to_not eq(unlock_1.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_2, student: @student).id).to_not eq(unlock_2.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: task_3, student: @student).id).to_not eq(unlock_4.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: manually_unlocked_task, student: @student).id).to_not eq(manual_unlock.id)
            expect(Unlock.find_by(school_class: school_class_1, unlockable: manually_unlocked_activity, student: @student).id).to_not eq(manual_unlock_2.id)
          end
        end
      end

      describe "when there are activities that have been unlocked" do
        let(:unlocked_activity) { FactoryGirl.create(:activity_page) }
        let(:activity_unlock) { Unlock.create(student: @student, school_class: school_class_1, unlockable: unlocked_activity) }
        let(:laplaya_task) { FactoryGirl.create(:laplaya_task) }
        let(:laplaya_unlock) { Unlock.create(student: @student, school_class: school_class_1, unlockable: laplaya_task) }
        let(:laplaya_response) { LaplayaTaskResponse.create(completed: true, student: @student, school_class: school_class_1, task: laplaya_task) }

        before do
          unlocked_activity
          task_1.activity_page.module_page.activity_pages << unlocked_activity
          activity_unlock
          laplaya_task
          task_1.activity_page.tasks << laplaya_task
          laplaya_unlock
          laplaya_response
          unlocked_activity.depend_on(laplaya_task)
        end

        it { should change { Unlock.count }.by(0) }
        it "should not lock the activity" do
          @student.reset_dependency_graph_for(school_class_1)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: unlocked_activity, student: @student)).to_not eq(nil)
        end
        it "should replace original activity unlock" do
          @student.reset_dependency_graph_for(school_class_1)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: unlocked_activity, student: @student).id).to_not eq(activity_unlock.id)
        end
      end

      describe "when a student has no responses" do
        before do
          @student.task_responses.each { |response|
            response.destroy
          }
        end

        it "should have only unlocks in different schools and for thinsg with no prerequisites" do
          @student.reset_dependency_graph_for(school_class_1)
          expect(Unlock.count).to eq(3)
        end
        it "should unlock only things that have no prerequisites" do
          @student.reset_dependency_graph_for(school_class_1)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: task_1.activity_page, student: @student)).to_not eq(nil)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: task_1, student: @student)).to_not eq(nil)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: task_2, student: @student)).to eq(nil)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: task_3, student: @student)).to eq(nil)
        end
        it "should replace the original unlocks" do
          @student.reset_dependency_graph_for(school_class_1)
          expect(Unlock.find_by(school_class: school_class_1, unlockable: task_1, student: @student).id).to_not eq(unlock_1.id)
        end

      end
    end

    describe "when a student is soft removed from a school_class_1" do
      subject { lambda { @student.soft_remove_from(school_class_1) } }

      it { should_not change { SchoolClass.count } }
      it "should cause student to no longer have school_class_1" do
        @student.soft_remove_from(school_class_1)
        expect(@student.school_classes).to_not include(school_class_1)
      end
      it "should cause school_class_1 to no longer have student" do
        @student.soft_remove_from(school_class_1)
        expect(school_class_1.students).to_not include(@student)
      end

      it { should_not change { Unlock.count } }
      it { should_not change { TaskResponse.count } }
      it { should_not change { Unlock.where(school_class: school_class_1).count } }
      it { should_not change { TaskResponse.where(school_class: school_class_1).count } }
    end
  end

end


