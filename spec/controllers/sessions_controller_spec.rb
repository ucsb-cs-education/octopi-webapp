require 'spec_helper'

describe StudentPortal::SessionsController, type: :controller do
  include StudentPortal::BaseHelper
  describe "For the student login" do
    describe "after logging in" do
      let(:school_class) { FactoryGirl.create(:school_class) }
      let(:new_student) { FactoryGirl.create(:student, school: school_class.school, school_class: school_class) }
      subject { page }
      before(:each) do
        school_class
        new_student
        sign_in_as_student(new_student)
      end
      describe "the class should be saved" do
        it { session[:school_class_id].should eq(school_class.id) }
      end
      describe "the remember token should be updated" do
        it { Digest::SHA1.hexdigest(session[:student_remember_token]).to_s.should eq(new_student.remember_token) }
      end
      describe "verify the current student" do
        it { current_student?(new_student).should eq(true) }
      end
      describe "verify that a student is signed in" do
        it { signed_in_student?.should eq(true) }
      end
      describe "verify the current school class" do
        it { current_school_class?(school_class).should eq(true) }
      end
      describe "verify that the page is redirected when a student signs in" do
        it do
          xhr :post, :create, session: {school: school_class.school, school_class: school_class, login_name: new_student.login_name,
          password: new_student.password}
          expect(response).to redirect_to(student_portal_root_url)
        end
      end
      describe "verify that a signed in student cannot access the login page" do
        it do
          xhr :post, :new
          expect(response).to redirect_to(student_portal_root_url)
        end
      end

      describe "and then logging out" do
        before {sign_out_student(new_student)}
        describe "verify that the student is signed out" do
          it { signed_in_student?.should eq(false) }
        end
        describe "verify that the session's remember token is nil" do
          it {session[:remember_token].should  eq(nil)}
        end
        describe "verify that the students remember token has changed " do
          it {new_student.remember_token.should_not eq(Digest::SHA1.hexdigest(session[:student_remember_token]).to_s)}
        end
        describe "verify that there is no current school class" do
          it { current_school_class?(school_class).should eq(false)}
        end
        describe "verify that there is no current student" do
          it {current_student?(new_student).should eq(false)}
        end
      end
    end
  end
end