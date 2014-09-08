require 'spec_helper'


describe "Task responses page", type: :feature do

  let(:assessment_task) { FactoryGirl.create(:assessment_task) }
  let(:feedback_assessment_task) { FactoryGirl.create(:assessment_task, give_feedback: true) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:another_class) { FactoryGirl.create(:school_class) }
  let(:another_student) { FactoryGirl.create(:student) }

  subject { page }

  before do
    2.times {
      assessment_task.assessment_questions << FactoryGirl.create(:assessment_question)
      feedback_assessment_task.assessment_questions << FactoryGirl.create(:assessment_question)
    }
    student
    another_class
    another_student.school_classes = []
    another_student.school_classes << another_class
    Student.all.each { |s|
      Unlock.create!(student: s, school_class: s.school_classes.first, unlockable: assessment_task)
      Unlock.create!(student: s, school_class: s.school_classes.first, unlockable: feedback_assessment_task)
      response_1 = AssessmentTaskResponse.create!(student: s, school_class: s.school_classes.first, task: assessment_task)
      response_2 = AssessmentTaskResponse.create!(student: s, school_class: s.school_classes.first, task: feedback_assessment_task)
      response_1.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_1.id,
                                                                                     assessment_question: assessment_task.assessment_questions.first,
                                                                                     selected: "[1]")
      response_1.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_1.id,
                                                                                     assessment_question: assessment_task.assessment_questions.second,
                                                                                     selected: "[0]")
      response_2.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_2.id,
                                                                                     assessment_question: feedback_assessment_task.assessment_questions.first,
                                                                                     selected: "[1]")
      response_2.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_2.id,
                                                                                     assessment_question: feedback_assessment_task.assessment_questions.second,
                                                                                     selected: "[0]")
    }
  end

  shared_examples_for 'the task response index page with no task param' do
    it { should have_link("#{CurriculumPage.find(assessment_task.curriculum_id)}", :href => curriculum_page_path(assessment_task.curriculum_id)) }
    it { should have_content("#{feedback_assessment_task.title}") }
    describe "after clicking on one of the tasks" do
      before do
        click_link "#{feedback_assessment_task.title}"
      end

      it "should bring you to the list of student responses for that task" do
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq(task_responses_path(task: feedback_assessment_task))
      end

      it { should have_link("#{student.school_classes.first}", :href => school_class_path(student.school_classes.first)) }
      it { should have_link("#{feedback_assessment_task.title}", :href => assessment_task_path(feedback_assessment_task)) }
      it { should have_link("", :href => task_responses_path) }
      it { should have_link("#{student.name}", :href => task_response_path(student.task_responses.second)) }

      describe "after click the student name link to view a single task response" do
        before do
          click_link("#{student.name}")
        end

        it { should have_content("Correct Answer: 2 Student Answer: 2") }
        it { should have_content("Correct Answer: 2 Student Answer: 1") }
        it { should have_link("#{student.name}'s progress", :href => school_class_student_progress_path(student.school_classes.first, student)) }

      end

    end
  end

  describe "as a super staff" do
    before do
      sign_in_as_staff(super_staff)
      visit task_responses_path
    end

    it_behaves_like 'the task response index page with no task param'
    it { should have_content("#{assessment_task.title}") }

    #at the view task 1 responses
    #it { should have_link("#{another_class}", :href => school_class_path(another_class)) }
    #it should also have another student link

  end

  describe "as a teacher" do
    before do
      sign_in_as_staff(teacher)
      visit task_responses_path
    end

    it_behaves_like 'the task response index page with no task param'
    it { should_not have_content("#{assessment_task.title}") }

    #at the view task 1 responses
    #it { should_not have_link("#{another_class}", :href => school_class_path(another_class)) }
    #it also should not have another student link

    #make sure to check and make sure the teacher cannot view any of the pages for task responses that do not give feedback
  end

end