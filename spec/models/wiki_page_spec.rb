require "spec_helper"

describe WikiPage do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_length_of(:title).is_at_most(70) }

  describe "uniqueness validation" do
    subject { create :wiki_page }

    it { is_expected.to validate_uniqueness_of :title }
  end
end