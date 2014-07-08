require 'spec_helper'

describe "page", type: :feature do
  subject{page}
  let(:user) { FactoryGirl.create(:staff, :super_staff) }

  shared_examples "a page" do

    describe "with a valid page" do
      it{should have_selector("a[href='#teacher-body']")}
      it{should have_selector("a[href='#student-body']")}
      it{should have_selector("#page-title")}
      it{should have_selector("#child-pages")}
    end

    describe "with the correct buttons" do
      it{should have_selector("input[id=update-page-btn]")}
    end

    describe "that has a correctly editable title",js:true do
      describe "before any editing" do
        it{should have_selector("span[id='page-title']")}
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
          it{should have_content("ThisIsATestToMakeSureYouCanStillClickOnABlankTitle")}
        end

        describe "should not be updatable" do
          before do
            title = find("#page-title")
            teacher_body = find("#teacher-body")
            clear_text_box(teacher_body)
            teacher_body.native.send_keys("INVALID UPDATE")
            title.click
          end
          it "when the update button is pressed" do
            expect do
              click_on("update-page-btn")
              page.driver.browser.switch_to.alert.accept
              wait_for_ajax
              me.reload
            end.not_to change(me, :teacher_body)
          end
        end
      end
    end

  describe "that can be edited correctly",js:true do
      before do
        teacher_body=find('#teacher-body')
        clear_text_box(teacher_body)
        teacher_body.native.send_keys("SampleTeacherBody")

        find("a[href='#student-body']").click
        student_body=find("#student-body")
        clear_text_box(student_body)
        student_body.native.send_keys("SampleStudentBody")

        title = find("#page-title")
        clear_text_box(title)
        title.native.send_keys("SampleTitle")
      end

      it "should update teacher body correctly"  do
        expect do
          click_on("update-page-btn")
          wait_for_ajax
          me.reload
        end.to change(me, :teacher_body).to('<p>SampleTeacherBody<br></p>')
      end

      it "should update student body correctly"  do
        expect do
          click_on("update-page-btn")
          wait_for_ajax
          me.reload
        end.to change(me, :student_body).to('<p>SampleStudentBody<br></p>')
      end

      it "should update title correctly"  do
        expect do
          click_on("update-page-btn")
          wait_for_ajax
          me.reload
        end.to change(me, :title).to('SampleTitle')
      end
    end
  end


  shared_examples "a child page" do

    describe "with a valid page" do
      it{should have_selector("a[href='#{thisPath}'][id='delete-page-link']")}
    end

    describe "that can be deleted" do
      it "should be deleted when delete is pressed" do
        expect do
          click_on("delete-page-link")
        end.to change(myModel, :count).by(-1)
      end
    end

    describe "that correctly links to parent" do
      it{should have_content("return to parent")}
      describe "after clicking on the parent link" do
        before do
          find("div.parent").find("a").click
        end
        it{should have_selector("a[href='#{thisPath}']")}
        it{should_not have_selector("a[href='#{thisPath}'][id='delete-page-link']")}
        describe "should correctly link back" do
          before do
            find("a[href='#{thisPath}']").click
          end
          it{should have_selector("a[href='#{thisPath}'][id='delete-page-link']")}

        end
      end
    end
  end


  shared_examples "a page with standard child structure" do

    describe "with the correct buttons" do
      it{should have_selector("input[id=add-new-child-btn]")}
    end

    describe "before clicking the add child button" do
      it{should_not have_selector("span[id='child-link']")}
    end

    describe "after clicking the add child button",js:true do
        before do
          find("#add-new-child-btn").click
          wait_for_ajax
        end
        it{should have_selector("span[id='child-link']",:count=>1)}
        describe "after updating",js:true do
          before do
            find("#add-new-child-btn").click
            wait_for_ajax
            find("#teacher-body").click
            find("#page-title").click
            click_on("update-page-btn")
            wait_for_ajax
            visit thisPath
          end
          it{should have_selector("span[id='child-link']",:count=>2)}
        end
    end

    describe "that has draggable children", js:true do
      before do
        3.times {find("#add-new-child-btn").click}
        wait_for_ajax
        page.execute_script %{
          $.getScript("/test/jquery.simulate.js", function() {
            $('#children li:first').simulate('drag', {dx: 0, dy: 80});
          });
        }
        find("#page-title").click
        click_on("update-page-btn")
        wait_for_ajax
        visit thisPath
      end

      it"should have preserved the change in order" do
        #what is happening here is that I am extracting the number in the id of each child link and comparing them
        childOne = find('#children').first( 'li')['id'].scan(/\d+/).first
        childTwo = find('#children').all( 'li').last['id'].scan(/\d+/).first
        (childOne > childTwo).should be_truthy
      end
    end
  end







  describe "Curriculum" do
    let(:curriculum){ FactoryGirl.create(:curriculum_page)}
    let(:myModel){CurriculumPage}
    let(:thisPath){curriculum_page_path(curriculum)}
    let(:me){curriculum}


    before do
      sign_in_as_staff(user)
      visit thisPath
    end

    it_behaves_like "a page"
    it_behaves_like "a page with standard child structure"
  end




  describe "Module" do
    let(:newmodule){ FactoryGirl.create(:module_page)}
    let(:myModel){ModulePage}
    let(:thisPath){module_page_path(newmodule)}
    let(:me){newmodule}

    before do
      sign_in_as_staff(user)
      visit thisPath
    end

    it_behaves_like "a page"
    it_behaves_like "a child page"
    it_behaves_like "a page with standard child structure"
  end




  describe "Activity" do
    let(:activity){ FactoryGirl.create(:activity_page)}
    let(:myModel){ActivityPage}
    let(:thisPath){activity_page_path(activity)}
    let(:me){activity}

    before do
      sign_in_as_staff(user)
      visit thisPath
    end

    describe "with the correct additional button" do
      it{should have_selector("input[id=add-new-assessment-child-btn]")}
    end

    it_behaves_like "a page"
    it_behaves_like "a child page"
    it_behaves_like "a page with standard child structure"

    describe "after clicking the assessment task button",js:true do
      before do
        find("#add-new-assessment-child-btn").click
        wait_for_ajax
      end
      it{should have_selector("span[id='child-link']",:count=>1)}
    end

    describe "after updating with both buttons",js:true do
      before do
        find("#add-new-child-btn").click
        wait_for_ajax
        find("#add-new-assessment-child-btn").click
        wait_for_ajax
        find("#teacher-body").click
        find("#page-title").click
        click_on("update-page-btn")
        wait_for_ajax
        visit thisPath
      end
      it{should have_selector("span[id='child-link']",:count=>2)}
    end
  end




  describe "Laplaya Task" do
    let(:laplayatask){ FactoryGirl.create(:laplaya_task)}
    let(:myModel){LaplayaTask}
    let(:thisPath){laplaya_task_path(laplayatask)}
    let(:me){laplayatask}

    before do
      sign_in_as_staff(user)
      visit thisPath
    end

    it_behaves_like "a page"
    it_behaves_like "a child page"

    describe "with the correct buttons" do
      it{should have_selector("input[id=update-page-btn]")}
      it{should have_selector("input[value=Clone]")}
    end
  end




  describe "Assessment Task" do
    let(:assessmenttask){ FactoryGirl.create(:assessment_task)}
    let(:myModel){AssessmentTask}
    let(:thisPath){assessment_task_path(assessmenttask)}
    let(:me){assessmenttask}

    before do
      sign_in_as_staff(user)
      visit thisPath
    end

    it_behaves_like "a page"
    it_behaves_like "a child page"
    it_behaves_like "a page with standard child structure"


  end
end