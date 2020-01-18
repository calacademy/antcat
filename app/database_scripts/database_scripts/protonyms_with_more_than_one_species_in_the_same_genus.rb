module DatabaseScripts
  class ProtonymsWithMoreThanOneSpeciesInTheSameGenus < DatabaseScript
    def results
      dups = Species.joins(:name).group("protonym_id, SUBSTRING_INDEX(names.name, ' ', 1)").having("COUNT(taxa.id) > 1")
      Protonym.where(id: dups.select(:protonym_id))
    end
  end
end

__END__

category: Catalog
tags: [new!]

description: >
  Some are misspellings, which I'm not sure how to handle (they do not fit the current database structure 100%).


  Other are obsolete combinations with different gender agreements -- these do commonly appear in print due to
  confusion over Latin grammar, but many cases on AntCat may simple be incorrect.


  There are also records with very different epithets; they also appear in %dbscript:ProtonymsWithTaxaWithVeryDifferentEpithets

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon

  - TypeTaxaAssignedToMoreThanOneTaxon