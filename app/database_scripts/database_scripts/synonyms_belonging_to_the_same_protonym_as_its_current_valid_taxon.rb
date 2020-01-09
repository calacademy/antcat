module DatabaseScripts
  class SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon < DatabaseScript
    def results
      Taxon.synonyms.joins(:current_valid_taxon).where("taxa.protonym_id = current_valid_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_valid_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :current_valid_taxon_status, :shared_protonym
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,

            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,

            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: This junior synonym belongs to the same protonym as its current valid taxon

description: >

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms