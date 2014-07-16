require 'spec_helper'

shared_examples_for 'pages laplaya cloning' do
  describe "when told to clone another laplaya file that the user has access to" do
    let(:another_laplaya_file) { FactoryGirl.create(:laplaya_file, owner: current_user) }
    it 'should redirect back to the page' do
      patch laplaya_clone_action, id: myself.id, laplaya_file: {laplaya_file: another_laplaya_file.id}
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(my_path)
    end
    it 'should update the underlying model' do
      patch laplaya_clone_action, id: myself.id, laplaya_file: {laplaya_file: another_laplaya_file.id}
      expect(laplaya_file_being_cloned_to.file_name).to eq(another_laplaya_file.file_name)
      expect(laplaya_file_being_cloned_to.project).to eq(another_laplaya_file.project)
      expect(laplaya_file_being_cloned_to.media).to eq(another_laplaya_file.media)
      expect(laplaya_file_being_cloned_to.public).to eq(false)
    end
  end
end
