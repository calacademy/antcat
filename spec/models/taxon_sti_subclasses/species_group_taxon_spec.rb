# frozen_string_literal: true

require 'rails_helper'

describe SpeciesGroupTaxon do
  describe 'validations' do
    describe '#ensure_protonym_is_a_species_group_name' do
      let(:taxon) { create :species }
      let(:genus_name) { create :genus_name }

      it 'must have genus-group protonym names' do
        expect { taxon.protonym.name = genus_name }.to change { taxon.valid? }.to(false)
        expect(taxon.errors[:base]).
          to eq ["Species and subspecies must have protonyms with species-group names"]
      end
    end
  end

  describe "#recombination?" do
    context "when genus part of name is different than genus part of protonym" do
      let(:taxon) { create :species, name_string: 'Atta minor' }

      before do
        protonym_name = create :species_name, name: 'Eciton minor'
        taxon.protonym.update!(name: protonym_name)
      end

      specify { expect(taxon.recombination?).to eq true }
    end

    context "when genus part of name is same as genus part of protonym" do
      let(:taxon) { create :species, name_string: 'Atta maxus' }

      before do
        protonym_name = create :species_name, name: 'Atta maxus'
        taxon.protonym.update!(name: protonym_name)
      end

      specify { expect(taxon.recombination?).to eq false }
    end
  end
end
