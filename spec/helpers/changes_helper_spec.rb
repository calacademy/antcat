# coding: UTF-8
require 'spec_helper'

describe ChangesHelper do

  describe "Formatting attributes" do

    it "should concatenate attributes into a comma-separated list" do
      genus = create_genus hong: true, nomen_nudum: true
      helper.format_change_attributes(genus).should == 'Hong, <i>nomen nudum</i>'
    end

    it "should concatenate protonym attributes into a comma-separated list" do
      protonym = FactoryGirl.create :protonym, sic: true, fossil: true
      genus = create_genus protonym: protonym
      helper.format_change_protonym_attributes(genus).should == 'Fossil, <i>sic</i>'
    end

  end
end
