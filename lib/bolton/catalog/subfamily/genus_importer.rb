# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer

  def parse_genus attributes = {}, options = {}
    options = options.reverse_merge :header => :genus_header
    return unless @type == options[:header]
    Progress.method

    name = @parse_result[:genus_name] || @parse_result[:name]
    parse_next_line

    headline = consume :genus_headline
    name ||= headline[:protonym][:genus_name]
    fossil ||= headline[:protonym][:fossil]

    taxonomic_history = parse_genus_taxonomic_history

    genus = Genus.import(
      :name => name,
      :fossil => fossil,
      :protonym => headline[:protonym],
      :note => headline[:note].try(:[], :text),
      :type_species => headline[:type_species],
      :taxonomic_history => taxonomic_history,
      :attributes => attributes
    )
    Progress.info "Created #{genus.name}"

    parse_homonym_replaced_by_genus genus
    parse_genus_references genus
    genus
  end

  def parse_genus_taxonomic_history
    Progress.method
    parsed_taxonomic_history = []
    if @type == :taxonomic_history_header
      parse_next_line
      while @type == :texts
        parsed_taxonomic_history << Bolton::Catalog::TextToTaxt.convert(@parse_result[:texts].first[:text])
        parse_next_line
      end
    end
    parsed_taxonomic_history
  end

  def parse_genus_references genus
    return unless @type == :genus_references_header || @type == :genus_references_see_under
    Progress.method

    multiple_reference_sections = @type != :genus_references_see_under

    texts = []
    parse_next_line
    collect_reference_section texts
    collect_reference_section texts if multiple_reference_sections && @type == :reference_section

    genus.update_attribute :references_taxt, Bolton::Catalog::TextToTaxt.convert(texts)
  end

  def collect_reference_section texts
    if @type == :texts
      texts.concat @parse_result[:texts] if @parse_result[:texts]
      @parse_result[:texts] = texts
      @parse_result[:type] = @type = :reference_section
      Progress.info 'reparsed as reference_section'
      parse_next_line
    end
  end

  def parse_homonym_replaced_by_genus replaced_by_genus
    genus = parse_genus({:status => 'homonym'}, :header => :homonym_replaced_by_genus_header)
    return '' unless genus
    Progress.method

    genus.update_attribute :homonym_replaced_by, replaced_by_genus
  end

  #def parse_junior_synonyms_of_genus genus
    #return '' unless @type == :junior_synonyms_of_genus_header
    #Progress.method

    #parse_next_line

    #parse_junior_synonym_of_genus(genus) while @type == :genus_headline

  #end

  #def parse_junior_synonym_of_genus genus
    #Progress.method
    #name = @parse_result[:genus_name]
    #fossil = @parse_result[:fossil]
    #taxonomic_history = @paragraph
    #parse_next_line
    #taxonomic_history << parse_genus_taxonomic_history
    #genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => genus,
                          #:subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    #Progress.info "Created #{genus.name} junior synonym of genus"
    #parse_homonym_replaced_by_genus(genus)
#  end

  def parse_genera_lists parent_rank, parent_attributes = {}
    return unless @type == :genera_list
    Progress.method

    while @type == :genera_list
      @parse_result[:genera].each do |genus|
        attributes = {:name => genus[:name], :fossil => genus[:fossil], :status => genus[:status] || 'valid'}.merge parent_attributes
        attributes.merge!(:incertae_sedis_in => parent_rank.to_s) if @parse_result[:incertae_sedis]

        name = genus[:name]
        genus = ::Genus.find_by_name name
        if genus
          # Several genera are listed both as incertae sedis in subfamily, and as a genus of an incertae sedis tribe
          if ['Zherichinius', 'Miomyrmex'].include? name
            genus.update_attributes attributes
          else
            raise "Genus #{name} found in more than one list"
          end
        else
          ::Genus.create! attributes
        end
      end

      parse_next_line
    end

  end

  #################################################################
  # parse a subfamily or tribe's genera
  def parse_genera attributes = {}
    return unless @type == :genera_header || @type == :genus_header
    Progress.method

    parse_next_line if @type == :genera_header
    parse_genus attributes while @type == :genus_header
  end

  def parse_genera_of_hong
    return unless @type == :genera_of_hong_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
  end

  def parse_genera_incertae_sedis expected_header = :genera_incertae_sedis_header
    return unless @type == expected_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
  end

end
