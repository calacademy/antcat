class TaxonDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  public def statistics options = {}
    statistics = @taxon.statistics or return ''
    content_tag :div, Formatters::StatisticsFormatter.statistics(statistics, options), class: 'statistics'
  end

  public def genus_species_header_notes_taxt
    if @taxon.genus_species_header_notes_taxt.present?
      content_tag :div, detaxt(@taxon.genus_species_header_notes_taxt), class: 'genus_species_header_notes_taxt'
    end
  end

  public def headline
    content_tag :div, class: 'headline' do
      notes = headline_notes
      string = headline_protonym
      string << ' ' << headline_type
      string << ' ' << notes if notes
      string << ' ' << link_to_other_site if link_to_other_site
      string << ' ' << link_to_antwiki(@taxon) if link_to_antwiki(@taxon)
      string << ' ' << link_to_hol(@taxon) if link_to_hol(@taxon)
      string << ' ' << link_to_edit_taxon if link_to_edit_taxon
      string << ' ' << link_to_delete_taxon if link_to_delete_taxon
      string << ' ' << link_to_review_change if link_to_review_change

      string
    end
  end

  private def headline_protonym
    protonym = @taxon.protonym
    return ''.html_safe unless protonym
    string = protonym_name protonym
    string << ' ' << headline_authorship(protonym.authorship)
    string << locality(protonym.locality)
    add_period_if_necessary(string || '')
  end

  ##########
  private def headline_type
    string = ''.html_safe
    string << headline_type_name_and_taxt
    string << headline_biogeographic_region
    string << ' ' unless string.empty?
    string << headline_verbatim_type_locality
    string << ' ' unless string.empty?
    string << headline_type_specimen
    string.rstrip.html_safe
  end

  private def headline_type_name_and_taxt
    taxt = @taxon.type_taxt
    if not @taxon.type_name and taxt
      string = headline_type_taxt taxt
    else
      return ''.html_safe if not @taxon.type_name
      rank = @taxon.type_name.rank
      rank = 'genus' if rank == 'subgenus'
      string = "Type-#{rank}: ".html_safe
      string << headline_type_name + headline_type_taxt(taxt)
      string
    end
    content_tag :span, class: 'type' do
      add_period_if_necessary string
    end
  end

  private def headline_type_name
    type = Taxon.find_by_name @taxon.type_name.to_s
    return headline_type_name_link(type) if type
    headline_type_name_no_link @taxon.type_name, @taxon.type_fossil
  end

  private def headline_type_name_link type
    self.class.link_to_taxon type
  end

  private def headline_type_name_no_link type_name, fossil
    rank = type_name.rank
    rank = 'genus' if rank == 'subgenus'
    name = type_name.to_html_with_fossil fossil
    content_tag :span, name, class: "#{rank} taxon"
  end

  private def headline_type_taxt taxt
    add_period_if_necessary(detaxt taxt)
  end

  private def headline_biogeographic_region
    string = ''
    return string if @taxon.biogeographic_region.blank?
    string << ' ' unless string.length.zero?
    periodized_string = add_period_if_necessary @taxon.biogeographic_region
    string << periodized_string
    string
  end

  private def headline_verbatim_type_locality
    string = ''
    return string if @taxon.verbatim_type_locality.blank?
    string << '"'
    periodized_string = add_period_if_necessary @taxon.verbatim_type_locality
    string << periodized_string
    string << '"'
    string
  end

  private def headline_type_specimen
    string = ''.html_safe
    if @taxon.type_specimen_repository.present?
      periodized_string = add_period_if_necessary @taxon.type_specimen_repository
      string << periodized_string
    end
    if @taxon.type_specimen_code.present?
      string << ' ' unless string.empty?
      periodized_string = add_period_if_necessary @taxon.type_specimen_code
      string << periodized_string
    end
    if @taxon.type_specimen_url.present?
      string << ' ' unless string.empty?
      s = @taxon.type_specimen_url
      string << link(s, s)
    end
    string.html_safe
  end

  #########
  private def protonym_name protonym
    content_tag :b, content_tag(:span, Formatters::CatalogFormatter.protonym_label(protonym), class: 'protonym_name')
  end

  private def headline_authorship authorship
    return '' unless authorship
    return '' unless authorship.reference
    string = link_to_reference(authorship.reference, @user)
    string << ": #{authorship.pages}" if authorship.pages.present?
    string << " (#{authorship.forms})" if authorship.forms.present?
    string << ' ' << detaxt(authorship.notes_taxt) if authorship.notes_taxt
    content_tag :span, string, class: :authorship
  end

  private def locality locality
    return '' unless locality.present?
    locality = locality.upcase.gsub(/\(.+?\)/) {|text| text.titlecase}
    add_period_if_necessary ' ' + locality
  end

  private def headline_notes
    return unless @taxon.headline_notes_taxt.present?
    detaxt @taxon.headline_notes_taxt
  end

  ##########
  public def history
    if @taxon.history_items.present?
      content_tag :div, class: 'history' do
        @taxon.history_items.inject(''.html_safe) do |content, item|
          content << history_item(item)
        end
      end
    end
  end

  private def history_item item
    css_class = "history_item item_#{item.id}"
    content_tag :div, class: css_class, 'data-id' => item.id do
      content_tag :table do
        content_tag :tr do
          history_item_body item
        end
      end
    end
  end

  private def history_item_body_attributes
    {}
  end

  private def history_item_body item
    content_tag :td, history_item_body_attributes.merge(class: 'history_item_body') do
      add_period_if_necessary detaxt item.taxt
    end
  end

  ##########
  public def child_lists
    content = ''.html_safe
    content << child_lists_for_rank(@taxon, :subfamilies)
    content << child_lists_for_rank(@taxon, :tribes)
    content << child_lists_for_rank(@taxon, :genera)
    content << collective_group_name_child_list(@taxon)
    return unless content.present?
    content_tag :div, class: 'child_lists' do
      content
    end
  end

  private def child_lists_for_rank parent, children_selector
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Subfamily === parent && children_selector == :genera
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: false) +
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: true)
    else
      child_list_fossil_pairs parent, children_selector
    end
  end

  private def collective_group_name_child_list parent
    children_selector = :collective_group_names
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?
    child_list parent, parent.send(children_selector), false, collective_group_names: true
  end

  private def child_list_fossil_pairs parent, children_selector, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = parent.child_list_query children_selector, extinct_conditions
    extant = parent.child_list_query children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present?

    child_list(parent, extant, specify_extinct_or_extant, extant_conditions) +
    child_list(parent, extinct, specify_extinct_or_extant, extinct_conditions)
  end

  private def child_list parent, children, specify_extinct_or_extant, conditions = {}
    label = ''.html_safe
    return label unless children.present?

    label << 'Hong (2002) ' if conditions[:hong]

    if conditions[:collective_group_names]
      label << Status['collective group name'].to_s(children.count).humanize
    else
      label << Rank[children].to_s(children.count, conditions[:hong] ? nil : :capitalized)
    end

    if specify_extinct_or_extant
      label << ' ('
      label << (conditions[:fossil] ? 'extinct' : 'extant')
      label << ')'
    end

    if conditions[:incertae_sedis_in]
      label << ' <i>incertae sedis</i> in '.html_safe
    elsif conditions[:collective_group_names]
      label << ' in '
    else
      label << ' of '
    end

    label << Formatters::CatalogFormatter.taxon_label_span(parent, ignore_status: true)

    content_tag :div, class: :child_list do
      content = ''.html_safe
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << child_list_items(children)
      content << '.'
      content
    end
  end

  private def child_list_items children
    children.inject([]) do |string, child|
      string << self.class.link_to_taxon(child)
    end.join(', ').html_safe
  end

  ############
  public def references
    if @taxon.reference_sections.present?
      content_tag :div, class: 'reference_sections' do
        @taxon.reference_sections.inject(''.html_safe) do |content, section|
          content << reference_section(section)
        end
      end
    end
  end

  private def reference_section section
    content_tag :div, class: 'section' do
      [:title_taxt, :subtitle_taxt, :references_taxt].inject(''.html_safe) do |content, field|
        if section[field].present?
          content << content_tag(:div, detaxt(section[field]), class: field)
        end
        content
      end
    end
  end

  ############
  private def detaxt taxt
    return '' unless taxt.present?
    Taxt.to_string taxt, @user, expansion: expand_references?, formatter: self.class
  end

end