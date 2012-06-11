# coding: UTF-8
class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  belongs_to :tribe
  has_many :species

  def self.import data, attributes = {}
    transaction do
      protonym = Protonym.import data[:protonym]
      name = Name.import data

      headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes.merge!(
        genus:                data[:genus],
        name_object:          name,
        fossil:               data[:fossil] || false,
        status:               data[:status] || 'valid',
        synonym_of:           data[:synonym_of],
        protonym:             protonym,
        headline_notes_taxt:  headline_notes_taxt,
      )
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        type_species_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
        attributes[:type_taxon_taxt] = type_species_taxt
      end
      genus_group_taxon = create! attributes
      data[:taxonomic_history].each do |item|
        genus_group_taxon.taxonomic_history_items.create! taxt: item if item.present?
      end

      type_species = data[:type_species]
      if type_species
        target_name = type_species[:genus_name]
        target_name << ' (' << type_species[:subgenus_epithet] + ')' if type_species[:subgenus_epithet]
        target_name << ' '  << type_species[:species_epithet]
        ForwardReference.create! source_id: genus_group_taxon.id, target_name: target_name,
          fossil: type_species[:fossil]
      end

      genus_group_taxon
    end
  end

  def statistics
  end

end
