require 'spec_helper'

describe SpeciesGroupTaxon do
  it { is_expected.to validate_presence_of :genus }

  it "has its subfamily set from its genus" do
    genus = create_genus
    expect(genus.subfamily).not_to be_nil

    taxon = create :species_group_taxon, genus: genus, subfamily: nil
    expect(taxon.subfamily).to eq genus.subfamily
  end

  describe "#inherit_attributes_for_new_combination" do
    include RefactorTaxonFactoriesHelpers

    let(:new_comb_parent) { build_stubbed :genus }
    let(:new_comb) { build_new_taxon :species }
    let(:old_comb) do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "not 404"
      create :species, biogeographic_region: "Neotropic"
    end

    it "copies relevant fields from `old_comb`" do
      # We want to copy these.
      attributes = [:protonym, :biogeographic_region]

      # Confirm factory.
      attributes.each { |attribute| expect(old_comb.send(attribute)).to be_present }

      # Act and test
      new_comb.inherit_attributes_for_new_combination old_comb, new_comb_parent

      attributes.each do |attribute|
        expect(old_comb.send(attribute)).to eq new_comb.send(attribute)
      end
    end

    it "doesn't copy irrelevant fields`" do
      # TODO
    end

    it "sets the name" do
      expect(new_comb.name.name).to be_blank
      new_comb.inherit_attributes_for_new_combination old_comb, new_comb_parent
      expect(new_comb.name.name).to be_present
    end

    it "raises on invalid rank combinations" do
      new_comb = create_subspecies
      old_comb = create_species
      irrelevant_parent = create_subfamily

      expect do
        new_comb.inherit_attributes_for_new_combination old_comb, irrelevant_parent
      end.to raise_error "rank mismatch"
    end
  end
end
