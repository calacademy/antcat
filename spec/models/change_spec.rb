# coding: UTF-8
require 'spec_helper'

describe Change do
  before do
    @was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
  end
  after do
    PaperTrail.enabled = @was_enabled
  end

  it "has a version" do
    genus = create_genus
    change = Change.new
    change.paper_trail_version = genus.version
    change.save!
    change.reload
    change.paper_trail_version.should == genus.version
    change.paper_trail_version.should be_nil
  end

  it "should be able to be reified after being created" do
    genus = create_genus

    change = Change.new paper_trail_version: genus.versions(true).last
    taxon = change.reify
    taxon.should == genus
    taxon.class.should == Genus

    genus.update_attributes name_cache: 'Atta'

    change = Change.new paper_trail_version: genus.versions(true).last
    taxon = change.reify
    taxon.should == genus
    taxon.class.should == Genus
  end

end
