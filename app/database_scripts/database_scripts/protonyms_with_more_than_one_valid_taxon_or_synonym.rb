module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxonOrSynonym < DatabaseScript
    def results
      Protonym.joins(:taxa).
        where(taxa: { status: [Status::VALID, Status::SYNONYM] }).
        group(:protonym_id).having('COUNT(protonym_id) > 1').
        where.not(id: covered_in_related_scripts)
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa, :statuses_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
          ]
        end
      end
    end

    private

      def covered_in_related_scripts
        ProtonymsWithMoreThanOneValidTaxon.new.results.select(:id) +
          ProtonymsWithMoreThanOneSynonym.new.results.select(:id)
      end
  end
end

__END__

category: Protonyms
tags: [new!]

description: >
  Matches already appearing in these two scripts are excluded:


  * %dbscript:ProtonymsWithMoreThanOneSynonym

  * %dbscript:ProtonymsWithMoreThanOneValidTaxonOrSynonym

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon