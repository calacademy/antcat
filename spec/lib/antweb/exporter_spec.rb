require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do

    it "should export a subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(ponerinae).and_return 'history'
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, 'history']
    end

    it "should export a genus" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
    end

    it "should export a genus without a tribe" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = Genus.create! :name => 'Acanothognathus', :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
    end

    it "should not export invalid taxa" do
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      valid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      invalid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(valid_genus).and_return 'history'
      CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics).with(invalid_genus)
      @exporter.export_taxon(valid_genus).should == [subfamily.name, tribe.name, valid_genus.name, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
      @exporter.export_taxon(invalid_genus).should == nil
    end

    it "should not export an invalid taxon" do
      acalama = Factory :genus,  :status => 'synonym'
      CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics)
      @exporter.export_taxon(acalama).should == nil
    end

    describe "Exporting species" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'Taxonomic history'
        CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(species).and_return 'history'
        @exporter.export_taxon(species).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
      end

    end

    describe "Exporting subspecies" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta
        subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'Taxonomic history'
      CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(subspecies).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'history']
      end

    end
  end
end
