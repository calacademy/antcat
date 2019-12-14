module References
  class WhatLinksHere
    include Service

    def initialize reference, predicate: false
      @reference = reference
      @predicate = predicate
      @table_refs = []
    end

    def call
      Detax::TAXT_MODELS_AND_FIELDS.each do |(model, _table, field)|
        model.where("#{field} LIKE '%{ref #{reference.id}}%'").pluck(:id).each do |id|
          table_refs << table_ref(model.table_name, field.to_sym, id)
          return true if predicate
        end
      end

      citations.pluck(:id).each do |citation_id|
        table_refs << table_ref(Citation.table_name, :reference_id, citation_id)
        return true if predicate
      end

      nestees.pluck(:id).each do |reference_id|
        table_refs << table_ref('references', :nesting_reference_id, reference_id)
        return true if predicate
      end
      return false if predicate

      table_refs
    end

    private

      attr :table_refs
      attr_reader :reference, :predicate

      delegate :nestees, :citations, :id, to: :reference

      def table_ref table, field, id
        TableRef.new(table, field, id)
      end
  end
end
