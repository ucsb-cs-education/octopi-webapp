require 'spec_helper'

describe "Static pages", type: :feature do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before do
      sign_in_as_a_valid_staff
      visit root_path
    end
    let(:heading) { 'Octopi' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"
  end

end
