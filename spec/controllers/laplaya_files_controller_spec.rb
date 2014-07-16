require 'spec_helper'

describe StudentPortal::Laplaya::LaplayaFilesController, type: :controller do
  let(:student) { FactoryGirl.create(:student) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:invalid_project_data) { "<project></project>" }
  let(:json_file_name) { "hello world this is an rspec test" }

  shared_examples_for "creating a laplaya file with ajax" do
    it "should increment the LaplayaFile count" do
      laplaya_file #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public}
      end.to change(LaplayaFile, :count).by(1)
    end

    it "should respond with success: created" do
      xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public}
      expect(response.status).to eq(201)
    end

    it "should respond with the url of the created file" do
      xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public}
      expect(response.location).to eq(laplaya_file_url(LaplayaFile.last))
    end

    describe "with a directly set file_name" do
      it "should increment the LaplayaFile count" do
        laplaya_file #Call the variable so that it is evaluated outside the xhr block
        expect do
          xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public, file_name: json_file_name}
        end.to change(LaplayaFile, :count).by(1)
      end

      it "should respond with success: created" do
        xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public, file_name: json_file_name}
        expect(response.status).to eq(201)
      end

      it "should not observe the file_name from the json" do
        xhr :post, :create, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public, file_name: json_file_name}
        expect(LaplayaFile.last.file_name).to_not eq(json_file_name)
      end
    end

    describe "that is invalid" do
      describe "because it has no project data" do
        it "should not increment the LaplayaFile count" do
          laplaya_file #Call the variable so that it is evaluated outside the xhr block
          expect do
            xhr :post, :create, laplaya_file: {media: laplaya_file.media, public: laplaya_file.public}
          end.not_to change(LaplayaFile, :count)
        end

        it "should respond with error: bad request" do
          xhr :post, :create, laplaya_file: {media: laplaya_file.media, public: laplaya_file.public}
          expect(response.status).to eq(400)
        end
      end


      describe "because it has project data with no name" do
        it "should not increment the LaplayaFile count" do
          laplaya_file #Call the variable so that it is evaluated outside the xhr block
          expect do
            xhr :post, :create, laplaya_file: {project: invalid_project_data, media: laplaya_file.media, public: laplaya_file.public}
          end.not_to change(LaplayaFile, :count)
        end

        it "should respond with error: bad request" do
          xhr :post, :create, laplaya_file: {project: invalid_project_data, media: laplaya_file.media, public: laplaya_file.public}
          expect(response.status).to eq(400)
        end
      end
    end
  end

  shared_examples_for "updating an existing laplaya file with ajax" do
    let(:another_laplaya_file) { FactoryGirl.create(:laplaya_file) }
    it "should not increment the LaplayaFile count" do
      laplaya_file #Call the variable so that it is evaluated outside the xhr block
      another_laplaya_file
      expect do
        xhr :patch, :update, id: laplaya_file.id, laplaya_file: {project: another_laplaya_file.project, media: another_laplaya_file.media, public: true}
      end.to_not change(LaplayaFile, :count)
    end

    it "should respond with success: no_content" do
      xhr :patch, :update, id: laplaya_file.id, laplaya_file: {project: another_laplaya_file.project, media: another_laplaya_file.media, public: true}
      expect(response.status).to eq(204)
    end

    it "should change the existing file" do
      xhr :patch, :update, id: laplaya_file.id, laplaya_file: {project: another_laplaya_file.project, media: another_laplaya_file.media, public: true}
      laplaya_file.reload
      expect(laplaya_file.project).to eq(another_laplaya_file.project)
      expect(laplaya_file.media).to eq(another_laplaya_file.media)
      expect(laplaya_file.public).to be true
    end
  end

  shared_examples_for "updating an existing laplaya file without permission" do
    let(:another_staff) { FactoryGirl.create(:staff) }
    let(:another_laplaya_file) { FactoryGirl.create(:laplaya_file, owner: another_staff) }
    it "should not increment the LaplayaFile count" do
      laplaya_file #Call the variable so that it is evaluated outside the xhr block
      another_laplaya_file
      expect do
        xhr :patch, :update, id: laplaya_file.id, laplaya_file: {project: another_laplaya_file.project, media: another_laplaya_file.media, public: true}
      end.to_not change(LaplayaFile, :count)
    end

    it "should respond with error: access denied" do
      xhr :patch, :update, id: another_laplaya_file.id, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public}
      expect(response.status).to eq(403)
    end

    it "should not change the existing file" do
      xhr :patch, :update, id: another_laplaya_file.id, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: true}
      laplaya_file.reload
      expect(another_laplaya_file.project).to_not eq(laplaya_file.project)
      expect(another_laplaya_file.media).to_not eq(laplaya_file.media)
      expect(another_laplaya_file.public).to_not be true
    end

    it "should not update the file" do
      xhr :patch, :update, id: another_laplaya_file.id, laplaya_file: {project: laplaya_file.project, media: laplaya_file.media, public: laplaya_file.public}
      expect(response.status).to eq(403)
    end
  end


  describe "updating a LaplayaFile as a student" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: student) }
    before(:each) do
      sign_in_as(student)
    end
    include_examples "updating an existing laplaya file with ajax"
    include_examples "updating an existing laplaya file without permission"
  end

  describe "updating a LaplayaFile as a staff" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: staff) }
    before(:each) do
      sign_in_as(staff)
    end
    include_examples "updating an existing laplaya file with ajax"
    include_examples "updating an existing laplaya file without permission"
  end

  describe "updating a TaskBaseLaplayaFile as a super staff" do
    let(:laplaya_file) { FactoryGirl.create(:task_base_laplaya_file) }
    before(:each) do
      sign_in_as(super_staff)
    end
    include_examples "updating an existing laplaya file with ajax"
  end

  describe "updating a ProjectBaseLaplayaFile as a super staff" do
    let(:laplaya_file) { FactoryGirl.create(:project_base_laplaya_file) }
    before(:each) do
      sign_in_as(super_staff)
    end
    include_examples "updating an existing laplaya file with ajax"
  end

  describe "updating a SandboxBaseLaplayaFile as a super staff" do
    let(:laplaya_file) { FactoryGirl.create(:sandbox_base_laplaya_file) }
    before(:each) do
      sign_in_as(super_staff)
    end
    include_examples "updating an existing laplaya file with ajax"
  end

  describe "creating a LaplayaFile as a student" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: student) }
    before(:each) do
      sign_in_as(student)
    end
    include_examples "creating a laplaya file with ajax"
  end

  describe "creating a LaplayaFile as a staff" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: staff) }
    before(:each) do
      sign_in_as(staff)
    end
    include_examples "creating a laplaya file with ajax"
  end

end