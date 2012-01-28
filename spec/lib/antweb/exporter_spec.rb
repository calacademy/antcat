# coding: UTF-8
require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do
    it "should export a subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      Factory :genus, :subfamily => ponerinae, :tribe => nil
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', '<p class="taxon_statistics">1 genus</p><p>Ponerinae</p>']
    end

    it "should export fossil taxa" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      Factory :genus, :subfamily => ponerinae, :tribe => nil
      fossil = Factory :genus, :subfamily => ponerinae, :tribe => nil, :fossil => true, :name => 'Atta', :taxonomic_history => 'Atta'
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', '<p class="taxon_statistics">Extant: 1 genus</p><p class="taxon_statistics">Fossil: 1 genus</p><p>Ponerinae</p>']
      @exporter.export_taxon(fossil).should == ['Ponerinae', nil, 'Atta', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'TRUE', 'Atta']
    end

    it "should export a genus" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = Genus.create! :name => 'Acanothognathus', :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should not export invalid taxa" do
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      valid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      invalid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      unidentifiable_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'unidentifiable'
      unidentifiable_genus.should be_unidentifiable
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(unidentifiable_genus, :include_invalid => false).and_return 'history'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(valid_genus, :include_invalid => false).and_return 'history'
      CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics_for_antweb).with(invalid_genus, :include_invalid => false)
      @exporter.export_taxon(valid_genus).should == [subfamily.name, tribe.name, valid_genus.name, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(unidentifiable_genus).should == [subfamily.name, tribe.name, unidentifiable_genus.name, nil, nil, nil, 'FALSE', 'FALSE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(invalid_genus).should == nil
    end

    it "should not export an invalid taxon" do
      acalama = Factory :genus,  :status => 'synonym'
      CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics_for_antweb)
      @exporter.export_taxon(acalama).should == nil
    end

    describe "Exporting species" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a species without a tribe" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        atta = Factory :genus, :name => 'Atta', :subfamily => myrmicinae, :tribe => nil
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['Myrmicinae', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = Factory :genus, :name => 'Atta', :subfamily => nil, :tribe => nil
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['incertae_sedis', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end

    describe "Exporting subspecies" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta
        subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a subspecies without a tribe" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        atta = Factory :genus, :name => 'Atta', :subfamily => myrmicinae, :tribe => nil
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'history'
        subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = Factory :genus, :name => 'Atta', :subfamily => nil, :tribe => nil
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'history'
        subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['incertae_sedis', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end
  end
end
