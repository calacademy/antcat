module DatabaseScripts
  class NonValidTaxaWithACurrentValidTaxonThatIsNotValid < DatabaseScript
    def results
      Taxon.where.not(current_valid_taxon: nil).self_join_on(:current_valid_taxon).
        where.not(taxa_self_join_alias: { status: Status::VALID })
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :current_valid_taxon_status
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.current_valid_taxon),
            taxon.current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

tags: [new!, slow]
topic_areas: [catalog]