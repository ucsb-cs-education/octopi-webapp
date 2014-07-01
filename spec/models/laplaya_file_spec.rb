require 'spec_helper'

describe LaplayaFile do
  shared_examples_for "a laplaya file" do
    # Basic attributes
    it { should respond_to(:file_name) }
    it { should respond_to(:project) }
    it { should respond_to(:media) }
    it { should respond_to(:thumbnail) }
    it { should respond_to(:note) }
    it { should respond_to(:public) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    #STI
    it { should respond_to(:type) }

    it { should be_valid }

    describe '#to_s' do
      before do
        @laplaya_file.file_name = 'This is a test'
      end
      it 'returns the file name from the database' do
        expect(@laplaya_file.to_s).to eq('This is a test')
      end
    end

    describe 'when file_name is not present' do
      before { @laplaya_file.file_name = ' ' }
      it { should_not be_valid }
    end

    describe 'when file_name is too long' do
      before { @laplaya_file.file_name = 'a' * 101 }
      it { should_not be_valid }
    end

    describe 'when notes is not present' do
      before { @laplaya_file.note = ' ' }
      it { should be_valid }
    end

    describe 'when thumbnail is not present' do
      before { @laplaya_file.thumbnail = nil }
      it { should be_valid }
    end

    describe 'when we change the project xml' do
      let(:thumbnail) {(<<eod
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAKAAAAB4CAYAAAB1ovlvAAADCElEQVR4Xu3VMW5aARRE0e992L1ZDgUbcuMNeT14IRRJ5CJy4yQaRhnJOr+F9544XMHDj1/P4SEwEngQ4Eje2Q8BAQphKiDAKb/jAtTAVECAU37HBaiBqYAAp/yOC1ADUwEBTvkdF6AGpgICnPI7LkANTAUEOOV3XIAamAoIcMrvuAA1MBUQ4JTfcQFqYCogwCm/4wLUwFRAgFN+xwWogamAAKf8jgtQA1MBAU75HRegBqYCApzyOy5ADUwFBDjld1yAGpgKCHDK77gANTAVEOCU33EBamAqIMApv+MC1MBUQIBTfscFqIGpgACn/I4LUANTAQFO+R0XoAamAgKc8jsuQA1MBQQ45XdcgBqYCghwyu+4ADUwFRDglN9xAWpgKiDAKb/jAtTAVECAU37HBaiBqYAAp/yOC1ADUwEBfsF/Op2Ol5eX43K5TL+g735cgH/4hs/n8+9Xr9fr8fb2djw9PX33Jv7r5xPgX7g/R/j5rbfb7SNIz30CAhTgfQXdOS3Af/wLfn9///jFe3x8vJPc+GcBAX7Rw/Pz8/H6+np89Rcso46AADuOtoQCAgzhjHUEBNhxtCUUEGAIZ6wjIMCOoy2hgABDOGMdAQF2HG0JBQQYwhnrCAiw42hLKCDAEM5YR0CAHUdbQgEBhnDGOgIC7DjaEgoIMIQz1hEQYMfRllBAgCGcsY6AADuOtoQCAgzhjHUEBNhxtCUUEGAIZ6wjIMCOoy2hgABDOGMdAQF2HG0JBQQYwhnrCAiw42hLKCDAEM5YR0CAHUdbQgEBhnDGOgIC7DjaEgoIMIQz1hEQYMfRllBAgCGcsY6AADuOtoQCAgzhjHUEBNhxtCUUEGAIZ6wjIMCOoy2hgABDOGMdAQF2HG0JBQQYwhnrCAiw42hLKCDAEM5YR0CAHUdbQgEBhnDGOgIC7DjaEgoIMIQz1hEQYMfRllBAgCGcsY6AADuOtoQCAgzhjHUEBNhxtCUUEGAIZ6wjIMCOoy2hgABDOGMdAQF2HG0JBQQYwhnrCAiw42hLKPAT12n8qPmYkCQAAAAASUVORK5CYII=
eod
      ).strip}
      describe 'to an xml with no notes or thumbnail' do
        before do
          @laplaya_file.project = "<project name=\"TestProj for Rspec\"></project>"
          @laplaya_file.save
        end
        its(:file_name) { should eq("TestProj for Rspec") }
        its(:thumbnail) { should be_nil }
        its(:note) { should be }
        its(:note) { should be_blank }
      end

      describe 'to an xml with no notes but with a thumbnail' do
        before do
          @laplaya_file.project = "<project name=\"TestProj for Rspec\"><thumbnail>#{thumbnail}</thumbnail></project>"
          @laplaya_file.save
        end
        its(:file_name) { should eq("TestProj for Rspec") }
        its(:thumbnail) { should eq(thumbnail) }
        its(:note) { should be }
        its(:note) { should be_blank }
      end

      describe 'to an xml with notes but with no thumbnail' do
        before do
          @laplaya_file.project = "<project name=\"TestProj for Rspec\"><notes>Hello world!!!</notes></project>"
          @laplaya_file.save
        end
        its(:file_name) { should eq("TestProj for Rspec") }
        its(:thumbnail) { should be_nil }
        its(:note) { should eq("Hello world!!!") }
      end

      describe 'to an xml with notes and a thumbnail' do
        before do
          @laplaya_file.project = "<project name=\"TestProj for Rspec\"><notes>Hello world!!!</notes><thumbnail>#{thumbnail}</thumbnail></project>"
          @laplaya_file.save
        end
        its(:file_name) { should eq("TestProj for Rspec") }
        its(:thumbnail) { should eq(thumbnail) }
        its(:note) { should eq("Hello world!!!") }
      end

      describe 'to a non-xml string' do
        before do
          @laplaya_file.project = "asdf"
        end
        it { should_not be_valid }
        it { should have(1).error_on(:project) }
      end

      describe 'to an xml with a non-project root' do
        before do
          @laplaya_file.project = "<brokenxml name=\"hello world\"></brokenxml>"
        end
        it { should_not be_valid }
        it { should have(1).error_on(:project) }
      end
    end

  end

  describe 'base class' do

    before do
      @laplaya_file = FactoryGirl.create(:laplaya_file)
    end

    subject { @laplaya_file }
    it_should_behave_like "a laplaya file"

  end

  describe 'task_base_laplaya_file' do

    before do
      @laplaya_file = FactoryGirl.create(:task_base_laplaya_file)
    end

    subject { @laplaya_file }
    it_should_behave_like "a laplaya file"

  end

end


