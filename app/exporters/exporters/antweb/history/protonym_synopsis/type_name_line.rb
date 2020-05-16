# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ProtonymSynopsis
        class TypeNameLine
          include Service

          attr_private_initialize :taxon

          def call
            type_name_line
          end

          private

            delegate :type_taxt, :type_taxon, :protonym, to: :taxon, private: true

            def type_name_line
              string = ''.html_safe
              string << type_name_and_taxt
              string << AddPeriodIfNecessary[protonym.biogeographic_region]
              string.html_safe
            end

            def type_name_and_taxt
              return ''.html_safe unless type_taxon

              string = taxon.decorate.type_taxon_rank
              string << AntwebFormatter.link_to_taxon(type_taxon)

              if type_taxt
                string << AntwebFormatter.detax(type_taxt)
              end

              AddPeriodIfNecessary[string]
            end
        end
      end
    end
  end
end
