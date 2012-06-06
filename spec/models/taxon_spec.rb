# coding: UTF-8
require 'spec_helper'

describe Taxon do
  it "should require a name" do
    Factory.build(:taxon, name_object: nil).should_not be_valid
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.name.should == 'Cerapachynae'
    taxon.should be_valid
  end
  it "should have a name object" do
    name = FactoryGirl.create :name_object, name_object_name: 'Cerapachynae'
    taxon = FactoryGirl.create :taxon, name: 'Cerapachynae', name_object: name
    taxon.name_object.name_object_name.should == 'Cerapachynae'
    taxon.should be_valid
  end
  it "should be (Rails) valid with a nil status" do
    Taxon.new(:name => 'Cerapachynae', name_object: Factory(:name_object)).should be_valid
    Taxon.new(:name => 'Cerapachynae', name_object: Factory(:name_object), :status => 'valid').should be_valid
  end
  it "when status 'valid', should not be invalid" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_invalid
  end
  it "should be able to be unidentifiable" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_unidentifiable
    taxon.update_attribute :status, 'unidentifiable'
    taxon.should be_unidentifiable
    taxon.should be_invalid
  end
  it "should be able to be unavailable" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_unavailable
    taxon.should be_available
    taxon.update_attribute :status, 'unavailable'
    taxon.should be_unavailable
    taxon.should_not be_available
    taxon.should be_invalid
  end
  it "should be able to be excluded" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_excluded
    taxon.update_attribute :status, 'excluded'
    taxon.should be_excluded
    taxon.should be_invalid
  end
  it "should be able to be a synonym" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end
  it "should be able to be a fossil" do
    taxon = FactoryGirl.create :taxon, :name => 'Cerapachynae'
    taxon.should_not be_fossil
    taxon.fossil.should == false
    taxon.update_attribute :fossil, true
    taxon.should be_fossil
  end
  it "should raise if anyone calls #children directly" do
    lambda {Taxon.new.children}.should raise_error NotImplementedError
  end
  it "should be able to be a synonym of something else" do
    gauromyrmex = FactoryGirl.create :taxon, :name => 'Gauromyrmex'
    acalama = FactoryGirl.create :taxon, :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex
    acalama.reload
    acalama.should be_synonym
    acalama.reload.synonym_of.should == gauromyrmex
  end
  it "should be able to be a homonym of something else" do
    neivamyrmex = FactoryGirl.create :taxon, :name => 'Neivamyrmex'
    acamatus = FactoryGirl.create :taxon, :name => 'Acamatus', :status => 'homonym', :homonym_replaced_by => neivamyrmex
    acamatus.reload
    acamatus.should be_homonym
    acamatus.homonym_replaced_by.should == neivamyrmex
  end
  it "should be able to have an incertae_sedis_in" do
    myanmyrma = FactoryGirl.create :taxon, :name => 'Myanmyrma', :incertae_sedis_in => 'family'
    myanmyrma.reload
    myanmyrma.incertae_sedis_in.should == 'family'
    myanmyrma.should_not be_invalid
  end
  it "should be able to say whether it is incertae sedis in a particular rank" do
    myanmyrma = FactoryGirl.create :taxon, :name => 'Myanmyrma', :incertae_sedis_in => 'family'
    myanmyrma.reload
    myanmyrma.should be_incertae_sedis_in('family')
  end
  it "should be able to store tons of text in taxonomic history" do
    camponotus = FactoryGirl.create :taxon, :name => 'Camponotus', :taxonomic_history => '1234' * 100_000
    camponotus.reload.taxonomic_history.size.should == 4 * 100_000
  end

  describe "Current valid name" do
    it "if it's not a synonym: it's just the name" do
      taxon = Factory :taxon, name: 'Name'
      taxon.current_valid_name.should == 'Name'
    end
    it "if it is a synonym: the name of the target" do
      target = Factory :taxon, :name => 'Target'
      taxon = Factory :taxon, :name => 'Taxon', :status => 'synonym', :synonym_of => target, name_object: Factory(:name_object)
      taxon.current_valid_name.should == 'Target'
    end
    it "if it is a synonym of a synonym: the name of the target's target" do
      target_target = Factory :taxon, :name => 'Target_Target'
      target = Factory :taxon, :name => 'Target', :status => 'synonym', :synonym_of => target_target
      taxon = Factory :taxon, :name => 'Taxon', :status => 'synonym', :synonym_of => target
      taxon.current_valid_name.should == 'Target_Target'
    end
  end

  describe "Find name" do
    before do
      FactoryGirl.create :genus, :name => 'Monomorium'
      @monoceros = FactoryGirl.create :genus, :name => 'Monoceros'
      @rufa = FactoryGirl.create :species, :name => 'rufa', :genus => @monoceros
    end
    it "should return [] if nothing matches" do
      Taxon.find_name('sdfsdf').should == []
    end
    it "should return an exact match" do
      Taxon.find_name('Monomorium').first.name.should == 'Monomorium'
    end
    it "should return a prefix match" do
      Taxon.find_name('Monomor', 'beginning with').first.name.should == 'Monomorium'
    end
    it "should return a substring match" do
      Taxon.find_name('iu', 'containing').first.name.should == 'Monomorium'
    end
    it "should return multiple matches" do
      results = Taxon.find_name('Mono', 'containing')
      results.size.should == 2
    end
    it "should not return anything but subfamilies, tribes, genera and species" do
      FactoryGirl.create :subfamily, :name => 'Lepto'
      FactoryGirl.create :tribe, :name => 'Lepto'
      FactoryGirl.create :genus, :name => 'Lepto'
      FactoryGirl.create :subgenus, :name => 'Lepto'
      FactoryGirl.create :species, :name => 'Lepto'
      FactoryGirl.create :subspecies, :name => 'Lepto'
      results = Taxon.find_name 'Lepto'
      results.size.should == 4
    end
    it "should sort results by name" do
      FactoryGirl.create :subfamily, :name => 'Lepti'
      FactoryGirl.create :subfamily, :name => 'Lepta'
      FactoryGirl.create :subfamily, :name => 'Lepte'
      results = Taxon.find_name 'Lept', 'beginning with'
      results.map(&:name).should == ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxon.find_name 'Monoceros rufa'
        results.first.should == @rufa
      end
      it "should search for partial species name" do
        results = Taxon.find_name 'Monoceros ruf', 'beginning with'
        results.first.should == @rufa
      end
    end
  end

  describe ".rank" do
    it "should return a lowercase version" do
      FactoryGirl.create(:subfamily).rank.should == 'subfamily'
    end
  end

  describe "being a synonym of" do
    it "should not think it's a synonym of something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_synonym_of another_genus
    end
    it "should think it's a synonym of something when it is" do
      senior_synonym = FactoryGirl.create :genus
      junior_synonym = FactoryGirl.create :genus, :synonym_of => senior_synonym, :status => 'synonym'
      junior_synonym.should be_synonym_of senior_synonym
    end
  end

  describe "being a homonym replaced by something" do
    it "should not think it's a homonym replaced by something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_homonym_replaced_by another_genus
      genus.homonym_replaced.should be_nil
    end
    it "should think it's a homonym replaced by something when it is" do
      replacement = FactoryGirl.create :genus
      homonym = FactoryGirl.create :genus, :homonym_replaced_by => replacement, :status => 'homonym'
      homonym.should be_homonym_replaced_by replacement
      replacement.homonym_replaced.should == homonym
    end
  end

  describe "the 'valid' scope" do
    it "should only include valid taxa" do
      subfamily = FactoryGirl.create :subfamily
      replacement = FactoryGirl.create :genus, :subfamily => subfamily
      homonym = FactoryGirl.create :genus, :homonym_replaced_by => replacement, :status => 'homonym', :subfamily => subfamily
      synonym = FactoryGirl.create :genus, :synonym_of => replacement, :status => 'synonym', :subfamily => subfamily
      subfamily.genera.valid.should == [replacement]
    end
  end

  describe "the 'extant' scope" do
    it "should only include extant taxa" do
      subfamily = FactoryGirl.create :subfamily
      extant_genus = FactoryGirl.create :genus, :subfamily => subfamily
      FactoryGirl.create :genus, :subfamily => subfamily, :fossil => true
      subfamily.genera.extant.should == [extant_genus]
    end
  end

  describe "ordered by name" do
    it "should order by name" do
      zymacros = FactoryGirl.create :subfamily, :name => 'Zymacros'
      atta = FactoryGirl.create :subfamily, :name => 'Atta'
      Taxon.ordered_by_name.should == [atta, zymacros]
    end
  end

  describe "statistics (for the whole family)" do
    it "should return the statistics for each status of each rank" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => nil
      FactoryGirl.create :genus, :subfamily => subfamily, :status => 'homonym', :tribe => nil
      2.times {FactoryGirl.create :subfamily, :fossil => true}
      Taxon.statistics.should == {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 1, 'homonym' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}}
      }
    end

  end

  describe "Convert asterisks to daggers" do
    it "should convert an asterisk to a dagger" do
      taxon = FactoryGirl.create :subfamily
      taxon.taxonomic_history = '*'
      taxon.convert_asterisks_to_daggers!
      taxon.taxonomic_history.should == '&dagger;'
      taxon.reload.taxonomic_history.should == '&dagger;'
    end
    it "work OK if taxonomic history is nil" do
      taxon = FactoryGirl.create :subfamily,  :taxonomic_history => nil
      taxon.convert_asterisks_to_daggers!
      taxon.taxonomic_history.should be_nil
      taxon.reload.taxonomic_history.should be_nil
    end
  end

  describe "Protonym" do
    it "should have a protonym" do
      taxon = Family.create! :name => 'Formicidae', name_object: Factory(:name_object)
      taxon.protonym.should be_nil
      taxon.build_protonym :name => 'Formicariae'
    end
  end

  describe "Taxonomic history items" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.taxonomic_history_items.should be_empty
      taxon.taxonomic_history_items.create! :taxt => 'foo'
      taxon.reload.taxonomic_history_items.map(&:taxt).should == ['foo']
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.taxonomic_history_items.create! :taxt => '1'
      taxon.taxonomic_history_items.create! :taxt => '2'
      taxon.taxonomic_history_items.create! :taxt => '3'
      taxon.taxonomic_history_items.map(&:taxt).should == ['1','2','3']
      taxon.taxonomic_history_items.first.move_to_bottom
      taxon.taxonomic_history_items(true).map(&:taxt).should == ['2','3','1']
    end
  end

  describe "Reference sections" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.should be_empty
      taxon.reference_sections.create! :references => 'foo'
      taxon.reload.reference_sections.map(&:references).should == ['foo']
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.create! :references => '1'
      taxon.reference_sections.create! :references => '2'
      taxon.reference_sections.create! :references => '3'
      taxon.reference_sections.map(&:references).should == ['1','2','3']
      taxon.reference_sections.first.move_to_bottom
      taxon.reference_sections(true).map(&:references).should == ['2','3','1']
    end
  end

  describe "Child list queries" do
    before do
      @subfamily = FactoryGirl.create :subfamily, name: 'Dolichoderinae'
    end
    it "should find all genera for the taxon if there are no conditions" do
      FactoryGirl.create :genus, name: 'Atta', subfamily: @subfamily
      FactoryGirl.create :genus, name: 'Eciton', subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: 'Aneuretus', subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      @subfamily.child_list_query(:genera).map(&:name).sort.should == ['Aneuretus', 'Atta', 'Eciton']
      @subfamily.child_list_query(:genera, fossil: true).map(&:name).sort.should == ['Aneuretus', 'Eciton']
      @subfamily.child_list_query(:genera, incertae_sedis_in: 'subfamily').map(&:name).sort.should == ['Aneuretus']
    end
    it "should not include invalid taxa" do
      FactoryGirl.create :genus, name: 'Atta', subfamily: @subfamily, :status => 'synonym'
      FactoryGirl.create :genus, name: 'Eciton', subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: 'Aneuretus', subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      @subfamily.child_list_query(:genera).map(&:name).sort.should == ['Aneuretus', 'Eciton']
    end
  end

  describe "Cascading delete" do
    it "should delete the protonym when the taxon is deleted" do
      Taxon.count.should be_zero
      Protonym.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      Taxon.count.should == 1
      Protonym.count.should == 1

      genus.destroy
      Taxon.count.should be_zero
      Protonym.count.should be_zero
    end
    it "should delete history and reference sections when the taxon is deleted" do
      Taxon.count.should be_zero
      ReferenceSection.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      genus.reference_sections.create! title: 'title', references: 'references'
      ReferenceSection.count.should == 1

      genus.destroy
      ReferenceSection.count.should be_zero
    end
  end

end
