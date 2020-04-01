# frozen_string_literal: true

module Autocomplete
  class AutocompleteLinkableReferences
    include Service

    attr_private_initialize :search_query

    def call
      Autocomplete::FormatLinkableReferences[search_results]
    end

    private

      def search_results
        exact_id_match || References::Search::FulltextLight[search_query]
      end

      def exact_id_match
        return unless /^\d+ ?$/.match?(search_query)

        match = Reference.find_by(id: search_query)
        [match] if match
      end
  end
end
