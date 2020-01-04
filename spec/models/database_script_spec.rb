require 'rails_helper'

describe DatabaseScript do
  describe ".new_from_filename_without_extension" do
    it "returns a database script" do
      results = described_class.new_from_filename_without_extension "ExtantTaxaInFossilGenera"
      expect(results).to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end
  end

  describe ".safe_new_from_filename_without_extension" do
    it "returns a database script" do
      results = described_class.safe_new_from_filename_without_extension "ExtantTaxaInFossilGenera"
      expect(results).to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end

    context 'when database script does not exists' do
      it 'returns an "unfound database script"' do
        results = described_class.safe_new_from_filename_without_extension "BestPizza"
        expect(results).to be_a DatabaseScript::UnfoundDatabaseScript
      end
    end
  end

  describe "#cached_results" do
    let(:database_script) { DatabaseScripts::DatabaseTestScript.new }

    context 'when results is present' do
      it "doesn't call `#result` more than once" do
        expect(database_script).to receive(:results).once.and_return :stubbed

        database_script.send :cached_results
        database_script.send :cached_results
      end
    end

    context 'when results is `nil`' do
      it "doesn't call `#result` more than once" do
        expect(database_script).to receive(:results).once.and_return nil

        database_script.send :cached_results
        database_script.send :cached_results
      end
    end

    context 'when results is `false`' do
      it "doesn't call `#result` more than once" do
        expect(database_script).to receive(:results).once.and_return false

        database_script.send :cached_results
        database_script.send :cached_results
      end
    end

    described_class.all.each do |database_script|
      it "#{database_script.filename_without_extension} calls `#results` only once" do
        if database_script.respond_to? :results
          expect(database_script).to receive(:results).at_most(:once).and_call_original
        end
        database_script.render
      end
    end
  end

  describe '.record_in_results?' do
    context "when taxon is in the script's results" do
      let(:script) { DatabaseScripts::ExtantTaxaInFossilGenera }
      let(:extant_species) { create :species }

      specify do
        expect { extant_species.genus.update!(fossil: true) }.
          to change { script.record_in_results?(extant_species) }.
          from(false).to(true)
      end
    end
  end

  describe '#soft_validated?' do
    it 'returns true if the script is used for taxon soft-validations' do
      expect(Taxa::DatabaseScriptSoftValidationWarnings::DATABASE_SCRIPTS_TO_CHECK.first.new.soft_validated?).to eq true
      expect(DatabaseScripts::ValidSpeciesList.new.soft_validated?).to eq false
    end
  end

  describe "testing with a real script" do
    let(:script) { DatabaseScripts::ExtantTaxaInFossilGenera.new }

    describe "#to_param" do
      it "returns the filename without extension" do
        expect(script.to_param).to eq "extant_taxa_in_fossil_genera"
      end
    end

    describe "#title" do
      let(:script) { DatabaseScripts::FossilProtonymsWithNonFossilTaxa.new }

      it "fetches the title from the END data" do
        expect(script.title).to eq "Fossil protonyms with non-fossil taxa"
      end

      it "defaults to the humanized filename" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.title).to eq "Fossil protonyms with non fossil taxa"
      end
    end

    describe "#category" do
      it "fetches the category from the END data" do
        expect(script.category).to eq "Catalog"
      end

      it "defaults to a blank string" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.category).to eq ""
      end
    end

    describe "#tags" do
      it "fetches the tags from the END data" do
        expect(script.tags).to eq ["regression-test"]
      end

      it "defaults to an empty array" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.tags).to eq []
      end
    end

    describe "#issue_description" do
      it "fetches the issue description from the END data" do
        expect(script.issue_description).to eq "The parent of this taxon is fossil, but this taxon is extant."
      end

      it "defaults to nil" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.issue_description).to eq nil
      end
    end

    describe "#description" do
      it "fetches the description from the END data" do
        expect(script.description).to eq "*Prionomyrmex macrops* can be ignored.\n"
      end

      it "defaults to a blank string" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.description).to eq ""
      end
    end

    describe "#related_scripts" do
      it "fetches the related scripts from the END data" do
        end_data = HashWithIndifferentAccess.new(related_scripts: ['ValidSubspeciesInInvalidSpecies'])
        allow(script).to receive(:end_data).and_return end_data
        expect(script.related_scripts.size).to eq 1
        expect(script.related_scripts.first).to be_a DatabaseScripts::ValidSubspeciesInInvalidSpecies
      end

      context 'when the script itself is included in the related scripts' do
        it "does not include itself (to make it easier to copy-paste related scripts)" do
          end_data = HashWithIndifferentAccess.new(related_scripts: ['ValidSubspeciesInInvalidSpecies', 'ExtantTaxaInFossilGenera'])
          allow(script).to receive(:end_data).and_return end_data
          expect(script.related_scripts.size).to eq 1
          expect(script.related_scripts.first).to be_a DatabaseScripts::ValidSubspeciesInInvalidSpecies
        end
      end

      context 'when related scripts include a non-existing script' do
        it 'returns an "unfound database script"' do
          end_data = HashWithIndifferentAccess.new(related_scripts: ['CountriesInEurope'])
          allow(script).to receive(:end_data).and_return end_data
          related_script = script.related_scripts.first
          expect(related_script.title).to include "Error: Could not find database script with class name"
          expect(related_script.to_param).to eq 'countries_in_europe'
        end
      end

      it "defaults to an empty array" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.related_scripts).to eq []
      end
    end

    describe '#statistics' do
      context 'when script has no custom statistics' do
        it 'returns default statistics' do
          expect(script.statistics).to eq "Results: 0"
        end

        context 'when script has `hide_statistics`' do
          it 'returns nil' do
            end_data = HashWithIndifferentAccess.new(hide_statistics: true)
            allow(script).to receive(:end_data).and_return end_data
            expect(script.statistics).to eq nil
          end
        end
      end

      context 'when script has custom statistics' do
        before do
          def script.statistics
            'Custom results'
          end
        end

        it "returns the script's `#statistics`" do
          expect(script.statistics).to eq 'Custom results'
        end
      end
    end
  end
end
