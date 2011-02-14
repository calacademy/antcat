require 'spec_helper'

describe Bolton::GenusCatalogParser do
  it 'should handle a blank line' do
    Bolton::GenusCatalogParser.parse("\n").should == {:type => :blank}
  end

  it 'should handle complete garbage' do
    line = %{asdfj;jsdf}
    Bolton::GenusCatalogParser.parse(line).should == {:type => :not_understood}
  end

  it 'should handle all sorts of guff within the tags' do
    line = %{<b
      style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
      style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                      :subfamily => 'Myrmicinae', :tribe => 'Dacetini'}
  end

  describe 'parsing the genus name' do
    it 'should parse a normal genus name' do
      line = %{<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Dacetini'}
    end

    it 'should parse a fossil genus name' do
      line = %{*<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :fossil => true}
    end

    it 'should parse an unidentifiable genus name' do
      line = %{*<b><i><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Attaichnus', :status => :unidentifiable,
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini', :fossil => true}
    end

    it "should recognize an unavailable name" do
      line = %{<i><span style='color:purple'>ANCYLOGNATHUS</span></i> [<i>Nomen nudum</i>]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Ancylognathus', :status => :unavailable}
    end

    it "should handle when the bracketed remark at end has a trailing bracket in bold" do
      line = %{<i><span style="color:purple">MYRMECIUM</span></i> [<b>unavailable name]</b>}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Myrmecium', :status => :unavailable}
    end
  end

  describe "subgenus" do

    it "should recognize a subgenus" do
      line = %{#<b><i><span style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i>Lasius</i>]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :subgenus, :name => 'Acanthomyops', :genus => 'Lasius'}
    end

  end

  describe 'material inside brackets' do

    it 'should parse the subfamily and tribe' do
      line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acromyrmex',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini'}
    end

    it "should handle an extinct subfamily" do
      line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Myrmicinae]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Myrmicinae', :fossil => true}
    end

    it "should handle an extinct subfamily and extinct tribe" do
      line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Specomyrminae: *Sphecomyrmini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Protazteca',
                                                        :subfamily => 'Specomyrminae', :tribe => 'Sphecomyrmini', :fossil => true}
    end

    #it "should handle a parenthetical note" do
      #line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae (or so they say)]}
      #Bolton::GenusCatalogParser.parse(line).should ==
     #{:type => :genus, {:name => 'Protazteca', :subfamily => 'Dolichoderinae', :tribe => 'incertae_sedis', :available => true, :valid => true, :fossil => false}
    #end

    #describe 'incertae sedis' do
      #it "should handle an uncertain family" do
        #line = %{<b><i><span style='color:red'>MYANMYRMA</span></i></b> [<i>incertae sedis</i> in Formicidae]}
        #Bolton::GenusCatalogParser.parse(line).should ==
      #{:type => :genus, {:name => 'Myanmyrma', :subfamily => 'incertae_sedis', :available => true, :valid => true, :fossil => false}
      #end

      #it "should handle uncertainty in a family" do
        #line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae]}
        #Bolton::GenusCatalogParser.parse(line).should ==
       #{:type => :genus, {:name => 'Protazteca', :subfamily => 'Dolichoderinae', :tribe => 'incertae_sedis', :available => true, :valid => true, :fossil => false}
      #end

      #it "should handle an uncertain subfamily + tribe" do
        #line = %{<b><i><span style='color:red'>ELECTROPONERA</span></i></b> [<i>incertae sedis</i> in Ectatomminae: Ectatommini]}
        #Bolton::GenusCatalogParser.parse(line).should ==
        #{:type => :genus, {:name => 'Electroponera', :subfamily => 'Ectatomminae', :tribe => 'Ectatommini', :available => true, :valid => true, :fossil => false}
      #end

      #it "should handle an uncertain tribe" do
        #line = %{<b><i><span style='color:red'>PROPODILOBUS</span></i></b> [Myrmicinae: <i>incertae sedis</i> in Stenammini]}
        #Bolton::GenusCatalogParser.parse(line).should ==
         #{:type => :genus, {:name => 'Propodilobus', :subfamily => 'Myrmicinae', :tribe => 'Stenammini', :available => true, :valid => true, :fossil => false}
      #end

      #it "should ignore a question mark" do
        #line = %{<b><i><span style='color:red'>CANANEURETUS</span></i></b> [Aneuretinae?]}
        #Bolton::GenusCatalogParser.parse(line).should ==
          #{:type => :genus, {:name => 'Cananeuretus', :subfamily => 'Aneuretinae', :available => true, :valid => true, :fossil => false}
      #end

    end

    describe 'synonymy' do

      it "should recognize a synonym and point to its senior" do
        line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
      end

      it "should handle the closing bracket being in a useless span" do
        line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i><span style='font-style:normal'>]</span>}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
      end

      it "should recognize an invalid name that has no color (like Claude)" do
        line = %{<i>ACIDOMYRMEX</i> [junior synonym of <i>Rhoptromyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acidomyrmex', :status => :synonym, :synonym_of => 'Rhoptromyrmex'}
      end

    end

    #it 'should handle parens instead of brackets' do
      #line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini)}
      #Bolton::GenusCatalogParser.parse(line).should ==
            #{:type => :genus, {:name => 'Acromyrmex', :subfamily => 'Myrmicinae', :tribe => 'Attini', :available => true, :valid => true, :fossil => false}
    #end

    #it 'should handle paren at one end and bracket at the other' do
      #line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini]}
      #Bolton::GenusCatalogParser.parse(line).should ==
             #{:type => :genus, {:name => 'Acromyrmex', :subfamily => 'Myrmicinae', :tribe => 'Attini', :available => true, :valid => true, :fossil => false}
    #end


  #end
end
