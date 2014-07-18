require 'spec_helper'

describe "page", type: :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:staff, :super_staff) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }

  shared_examples "a page" do

    describe "with a valid page" do
      it { should have_link("Teacher Body") }
      it { should have_link("Student Body") }
      it { should have_selector("#page-title") }
      it { should have_selector("#child-pages") }
    end

    describe "with the correct buttons" do
      it { should have_button("Save changes to", disabled: true) }
    end

    describe "that has a correctly editable title", js: true do
      describe "before any editing" do
        it { should have_selector("span[id='page-title']") }
      end
      describe "after removing everything" do
        before do
          title = find("#page-title")
          clear_text_box(title)
        end

        describe "should still have an editable title" do
          before do
            title = find("#page-title")
            find("#teacher-body").click
            title.click
            title.native.send_keys("ThisIsATestToMakeSureYouCanStillClickOnABlankTitle")
          end
          it { should have_content("ThisIsATestToMakeSureYouCanStillClickOnABlankTitle") }
        end

        describe "should not be updatable" do
          before do
            title = find("#page-title")
            teacher_body = find("#teacher-body")
            clear_text_box(teacher_body)
            teacher_body.native.send_keys("INVALID UPDATE")
            title.click
          end
          it "when the update button is pressed", driver: :selenium do
            expect do
              wait_for_and_click_on_button("Save changes to")
              page.driver.browser.switch_to.alert.accept
              wait_for_ajax
              me.reload
            end.not_to change(me, :teacher_body)
          end
        end
      end
    end

    describe "that can be edited correctly", js: true do
      before do
        teacher_body=find('#teacher-body')
        teacher_body.click
        teacher_body.set("SampleTeacherBody")

        find_link("Student Body").trigger('click')
        student_body=find("#student-body")
        student_body.click
        student_body.set("SampleStudentBody")

        title = find("#page-title")
        title.click
        title.set("SampleTitle")
      end

      it "should update teacher body correctly" do
        expect do
          wait_for_and_click_on_button("Save changes to")
          wait_for_ajax
          me.reload
        end.to change(me, :teacher_body)
        expect(RSpecSanitizer::sanitize(me.teacher_body)).to eq('SampleTeacherBody')
      end

      it "should update student body correctly" do
        expect do
          wait_for_and_click_on_button("Save changes to")
          wait_for_ajax
          me.reload
        end.to change(me, :student_body)
        expect(RSpecSanitizer::sanitize(me.student_body)).to eq('SampleStudentBody')
      end

      it "should update title correctly" do
        expect do
          wait_for_and_click_on_button("Save changes to")
          wait_for_ajax
          me.reload
        end.to change(me, :title).to('SampleTitle')
      end
    end
  end


  shared_examples "a child page" do

    describe "with a valid page" do
      it { should have_link("Delete #{me.title}") }
    end

    describe "that can be deleted" do
      it "should be deleted when delete is pressed" do
        expect do
          click_link("Delete #{me.title}")
        end.to change(myModel, :count).by(-1)
      end
      describe "that correctly redirects to parent", js: true do
        it "should redirect to parent when deleted", driver: :selenium do
          click_link('return to parent')
          parent_path = current_path
          visit thisPath
          click_link("Delete #{me.title}")
          page.driver.browser.switch_to.alert.accept
          wait_for_ajax
          expect(current_path).to eq(parent_path)
        end
      end
    end

    describe "that correctly links to parent" do
      it { should have_content("return to parent") }
      describe "after clicking on the parent link" do
        before do
          click_link('return to parent')
        end
        it { should have_link("#{me.title}") }
        it { should_not have_link("Delete #{me.title}") }
        describe "should correctly link back" do
          before do
            click_link("#{me.title}")
          end
          it do
            should have_link("Delete #{me.title}")
          end
        end
      end
    end
  end


  shared_examples "a page with standard child structure" do

    describe "with the correct buttons" do
      it { should have_button("Add a new") }
    end

    describe "before clicking the add child button" do
      it { should_not have_css("li.page-child-li") }
    end

    describe "after clicking the add child button", js: true, driver: :selenium do
      before do
        click_button("Add a new", match: :first)
        wait_for_ajax
      end
      it { should have_css("li.page-child-li", :count => 1) }
      describe "after updating", js: true do
        before do
          click_button("Add a new", match: :first)
          wait_for_ajax
          find("#teacher-body").click
          find("#page-title").click
          wait_for_and_click_on_button("Save changes to")
          wait_for_ajax
          visit thisPath
        end
        it { should have_css("li.page-child-li", :count => 2) }
      end
    end

    describe "that has draggable children", js: true, driver: :selenium do
      before do
        3.times { click_button("Add a new", match: :first) }
        wait_for_ajax
        page.execute_script %{
          $.getScript("/test/jquery.simulate.js", function() {
            $('#children li:first').simulate('drag', {dx: 0, dy: 80});
          });
        }
        find("#page-title").click
        wait_for_and_click_on_button("Save changes to")
        wait_for_ajax
        visit thisPath
      end

      it "should have preserved the change in order" do
        #what is happening here is that I am extracting the number in the id of each child link and comparing them
        childOne = find('#children').first('li')['id'].scan(/\d+/).first
        childTwo = find('#children').all('li').last['id'].scan(/\d+/).first
        expect(childOne > childTwo).to eq(true)
      end
    end
  end

  shared_examples "a page that may not be edited" do
    describe "with a valid page" do
      it { should have_link("Teacher Body") } or it { should have_link("Student Body") }
      it { should have_selector("#page-title") }
      it { should have_selector("#child-pages") }
      it { should_not have_button("Add a new") }
      it { should_not have_link("Delete") }
      it { should_not have_button("Save changes to") }
    end

    describe "after attempting to edit the boxes", js: true do
      before do
        teacher_body=find('#teacher-body')
        teacher_body.native.send_keys("SampleTeacherBody")

        click_link("Student Body")
        student_body=find("#student-body")
        student_body.native.send_keys("SampleStudentBody")

        title = find("#page-title")
        title.native.send_keys("SampleTitle")
      end
      it { should_not have_content("SampleTeacherBody") }
      it { should_not have_content("SampleStudentBody") }
      it { should_not have_content("SampleTitle") }
    end

  end

  shared_examples "a page with dependencies" do
    describe "when editing dependencies" do

      shared_examples "a page depending on a task" do
        before do
          activity_2
          prereq_task
          myModule.activity_pages << activity_2
          activity_2.tasks << prereq_task
          visit thisPath
        end
        describe "with the add prerequisite form" do
          it { should have_selector("div[id=edit-dependencies]") }
        end

        describe "before a dependency is created" do
          it { should_not have_content("Depends on") }
          it { should have_selector("##{add_dependency_id} option[value='#{prereq_task.id.to_s}']") }
          describe "when another module exists" do
            let(:other_module) { FactoryGirl.create(:module_page) }
            let(:other_activity) { FactoryGirl.create(:activity_page, module_page: other_module) }
            let(:other_task) { FactoryGirl.create(:assessment_task, activity_page: other_activity) }
            before do
              other_module
              other_activity
              other_task
              visit thisPath
            end
            it { should_not have_selector("##{add_dependency_id} option[value='#{other_task.id.to_s}']") }
          end
        end

        describe "after a dependency is created", js: true do
          before do
            select(prereq_task.title, :from => add_dependency_id)
            click_on "Add New Prerequisite"
            wait_for_ajax
          end
          it { should have_content("Depends on") }
          it { should have_link(prereq_task.title) }
          it { should_not have_selector("##{add_dependency_id} option[value='#{prereq_task.id.to_s}']") }

          describe "after deleting a dependency", js: true do
            before do
              click_on "Remove"
              wait_for_ajax
            end
            it { should_not have_content("Depends on") }
            it { should_not have_link(prereq_task.title) }
            it { should have_selector("##{add_dependency_id} option[value='#{prereq_task.id.to_s}']") }
          end

          describe "after following the depends on link" do
            before do
              click_on "#{prereq_task.title}"
            end
            it { should have_link(me.title) }
            it "should link to the prerequisite task" do
              expect(current_path).to eq(prereq_path)
            end
          end
          describe "after clicking the corresponding is prerequisite to link", driver: :selenium do
            #diver: :selenium is set here because without it this test will fail unpredictably
            before do
              click_on "#{prereq_task.title}"
              click_on "#{me.title}"
            end
            it "should link back to the dependant" do
              expect(current_path).to eq(thisPath)
            end
          end
        end
      end


      describe "when depending on an assessment task" do
        let(:activity_2) { FactoryGirl.create(:activity_page, module_page: myModule) }
        let(:prereq_task) { FactoryGirl.create(:assessment_task, activity_page: activity_2) }
        let(:prereq_path) { assessment_task_path(prereq_task) }
        it_behaves_like "a page depending on a task"
      end

      describe "when depending on a laplaya task" do
        let(:activity_2) { FactoryGirl.create(:activity_page, module_page: myModule) }
        let(:prereq_task) { FactoryGirl.create(:laplaya_task, activity_page: activity_2) }
        let(:prereq_path) { laplaya_task_path(prereq_task) }
        it_behaves_like "a page depending on a task"
      end
    end
  end


  describe "Curriculum" do
    let(:curriculum) { FactoryGirl.create(:curriculum_page) }
    let(:myModel) { CurriculumPage }
    let(:thisPath) { curriculum_page_path(curriculum) }
    let(:me) { curriculum }

    describe "when authorized to edit" do
      before do
        sign_in_as_staff(user)
        visit thisPath
      end

      it_behaves_like "a page"
      it_behaves_like "a page with standard child structure"
    end

    describe "when not authorized to edit" do
      before do
        sign_in_as_staff(teacher)
        visit thisPath
      end

      it_behaves_like "a page that may not be edited"
    end
  end


  describe "Module" do
    let(:newmodule) { FactoryGirl.create(:module_page) }
    let(:myModel) { ModulePage }
    let(:thisPath) { module_page_path(newmodule) }
    let(:me) { newmodule }

    describe "when authorized to edit" do
      before do
        sign_in_as_staff(user)
        visit thisPath
      end

      it { should have_content("Edit LaPlaya") }
      it { should_not have_content("Open LaPlaya") }
      it { should have_content("Design Thinking Project File") }
      it { should have_content("Sandbox File") }

      describe "with the correct buttons" do
        it { should have_button("Save changes to", disabled: true) }
        it { should have_button("Clone") }
      end

      it_behaves_like "a page"
      it_behaves_like "a child page"
      it_behaves_like "a page with standard child structure"
    end

    describe "when not authorized to edit" do
      before do
        sign_in_as_staff(teacher)
        visit thisPath
      end

      it { should_not have_content("Edit LaPlaya") }
      it { should have_content("Open LaPlaya") }
      it { should have_content("Design Thinking Project File") }
      it { should have_content("Sandbox File") }

      describe "without a clone button" do
        it { should_not have_button("Clone") }
      end

      it_behaves_like "a page that may not be edited"
    end
  end


  describe "Activity" do
    let(:activity) { FactoryGirl.create(:activity_page) }
    let(:myModel) { ActivityPage }
    let(:thisPath) { activity_page_path(activity) }
    let(:add_dependency_id) { "activity_dependency_task_prerequisite_id" }
    let(:me) { activity }
    let(:myModule) { me.module_page }

    describe "when authorized to edit" do
      before do
        sign_in_as_staff(user)
        visit thisPath
      end

      describe "with the correct additional button" do
        it { should have_button("Add a new Assessment Task") }
      end

      it_behaves_like "a page"
      it_behaves_like "a child page"
      it_behaves_like "a page with standard child structure"
      it_behaves_like "a page with dependencies"

      describe "with a task" do
        let(:child_assessment_task) { FactoryGirl.create(:assessment_task, activity_page: me) }
        let(:child_laplaya_task) { FactoryGirl.create(:laplaya_task, activity_page: me) }
        before do
          child_assessment_task
          child_laplaya_task
          visit thisPath
        end
        it { should_not have_selector("##{add_dependency_id} option[value='#{child_assessment_task.id.to_s}']") }
        it { should_not have_selector("##{add_dependency_id} option[value='#{child_laplaya_task.id.to_s}']") }
      end

      describe "after clicking the assessment task button", js: true, driver: :selenium do
        before do
          click_button("Add a new Assessment Task")
          wait_for_ajax
        end
        it { should have_css("li.page-child-li", :count => 1) }
      end

      describe "after updating with both buttons", js: true do
        before do
          click_button("Add a new LaPlaya Task")
          wait_for_ajax
          click_button("Add a new Assessment Task")
          wait_for_ajax
          find("#teacher-body").click
          find("#page-title").click
          wait_for_and_click_on_button("Save changes to")
          wait_for_ajax
          visit thisPath
        end
        it { should have_css("li.page-child-li", :count => 2) }
      end
    end

    describe "when not authorized to edit" do
      before do
        sign_in_as_staff(teacher)
        visit thisPath
      end

      it_behaves_like "a page that may not be edited"
      it { should_not have_selector("div[id=edit-dependencies]") }
    end
  end


  describe "Laplaya Task" do
    let(:laplayatask) { FactoryGirl.create(:laplaya_task) }
    let(:myModel) { LaplayaTask }
    let(:thisPath) { laplaya_task_path(laplayatask) }
    let(:add_dependency_id) { "task_dependency_prerequisite_id" }
    let(:me) { laplayatask }
    let(:myModule) { me.activity_page.module_page }

    describe "when authorized to edit" do

      before do
        sign_in_as_staff(user)
        visit thisPath
      end

      it { should have_content("Edit LaPlaya") }
      it { should have_content("Task Base LaPlaya File") }

      it_behaves_like "a page"
      it_behaves_like "a child page"
      it_behaves_like "a page with dependencies"

      describe "with the correct buttons" do
        it { should have_button("Save changes to", disabled: true) }
        it { should have_button("Clone") }
      end
    end

    describe "when not authorized to edit" do
      before do
        sign_in_as_staff(teacher)
        visit thisPath
      end

      it { should_not have_content("Edit LaPlaya") }
      it { should have_content("Open LaPlaya") }
      it { should have_content("Task Base LaPlaya File") }
      it { should_not have_selector("div[id=edit-dependencies]") }

      describe "without a clone button" do
        it { should_not have_button("Clone") }
      end

      it_behaves_like "a page that may not be edited"
      describe "with the correct text for accessing the laplaya file" do

        it { should_not have_content("Edit LaPlaya") }
        it { should have_content("Open LaPlaya") }
      end
    end
  end

  describe "Assessment Task" do
    let(:assessmenttask) { FactoryGirl.create(:assessment_task) }
    let(:myModel) { AssessmentTask }
    let(:thisPath) { assessment_task_path(assessmenttask) }
    let(:add_dependency_id) { "task_dependency_prerequisite_id" }
    let(:me) { assessmenttask }
    let(:myModule) { me.activity_page.module_page }

    describe "when authorized to edit" do
      before do
        sign_in_as_staff(user)
        visit thisPath
      end

      it_behaves_like "a page"
      it_behaves_like "a child page"
      it_behaves_like "a page with standard child structure"
      it_behaves_like "a page with dependencies"
    end

    describe "when not authorized to edit" do
      before do
        sign_in_as_staff(teacher)
        visit thisPath
      end
      it_behaves_like "a page that may not be edited"
      it { should_not have_selector("div[id=edit-dependencies]") }
    end
  end
end