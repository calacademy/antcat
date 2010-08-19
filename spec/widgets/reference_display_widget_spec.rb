require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Reference display widget" do
  it "should format the reference" do
    reference = Factory(:reference, :authors => "Forel, A.", :year => "1874", :title => "Les fourmis de la Suisse",
                              :citation => "Neue Denkschriften 26:1-452")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
  end

  it "should add a period after the title if none exists" do
    reference = Factory(:reference, :authors => "authors", :year => "year", :title => "No period", :citation => "citation")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'authors year. No period. citation.'
  end

  it "should not add a period after the title if there's already one" do
    reference = Factory(:reference, :authors => "authors", :year => "year", :title => "With period.", :citation => "citation")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'authors year. With period. citation.'
  end

  it "should add a period after the citation if none exists" do
    reference = Factory(:reference, :authors => "authors", :year => "year", :title => "title", :citation => "No period")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'authors year. title. No period.'
  end

  it "should not add a period after the citation if there's already one" do
    reference = Factory(:reference, :authors => "authors", :year => "year", :title => "title", :citation => "With period.")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'authors year. title. With period.'
  end
end

