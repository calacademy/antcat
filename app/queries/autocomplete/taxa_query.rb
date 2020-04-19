# frozen_string_literal: true

# TODO: Use Solr or ElasticSearch.

module Autocomplete
  class TaxaQuery
    include Service

    attr_private_initialize :search_query, [rank: nil]

    def call
      (exact_id_match || search_results).map do |taxon|
        {
          id: taxon.id,
          name: taxon.name_cache,
          name_html: taxon.name_html_cache,
          name_with_fossil: taxon.name_with_fossil,
          author_citation: taxon.author_citation
        }
      end
    end

    private

      def search_results
        taxa = Taxon.where("name_cache LIKE ? OR name_cache LIKE ?", crazy_search_query, not_as_crazy_search_query)
        taxa = taxa.where(type: rank) if rank.present?
        taxa.includes(:name, protonym: { authorship: { reference: :author_names } }).
          references(:reference_author_names).limit(10)
      end

      # TODO: Not tested.
      def crazy_search_query
        search_query.split('').join('%') + '%'
      end

      def not_as_crazy_search_query
        "%#{search_query}%"
      end

      def exact_id_match
        return unless /^\d{6} ?$/.match?(search_query)

        match = Taxon.find_by(id: search_query)
        [match] if match
      end
  end
end