# coding: UTF-8
module ChangesHelper
  include Formatters::Formatter
  include Formatters::ChangesFormatter

  def link_to_taxon taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  def format_adder_name change_type, user
    if change_type == "create"
      user_verb = "added"
    elsif change_type == "delete"
      user_verb = "deleted"
    else
      user_verb = "changed"
    end

    ("#{format_doer_name user} "+ user_verb).html_safe
  end

  def format_taxon_name name
    name.name_html.html_safe
  end

  def format_rank rank
    rank.display_string
  end

  def format_status status
    Status[status].to_s
  end

  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_attributes taxon
    string = []
    string << 'Fossil' if taxon.fossil?
    string << 'Hong' if taxon.hong?
    string << '<i>nomen nudum</i>' if taxon.nomen_nudum?
    string << 'unresolved homonym' if taxon.unresolved_homonym?
    string << 'ichnotaxon' if taxon.ichnotaxon?
    string.join(', ').html_safe
  end

  def format_protonym_attributes taxon
    protonym = taxon.protonym
    string = []
    string << 'Fossil' if protonym.fossil?
    string << '<i>sic</i>' if protonym.sic?
    string.join(', ').html_safe
  end

  def format_type_attributes taxon
    string = []
    string << 'Fossil' if taxon.type_fossil?
    string.join(', ').html_safe
  end

  def format_taxt taxt
    Taxt.to_string taxt, current_user
  end

  def edit_button taxon
    if taxon.can_be_edited_by? current_user
      button 'Edit', 'edit_button', 'data-edit-location' => edit_taxa_path(taxon)
    end
  end

  def undo_button taxon, change
    # bull; this should tag with current change id.
    if taxon.can_be_edited_by? current_user
      button 'Undo', 'undo_button', 'data-undo-id' => change.id, class: 'undo_button_' + change.id.to_s
    end
  end

  def approve_button taxon
    if taxon.can_be_approved_by? current_user
      button 'Approve', 'approve_button', 'data-change-id' => taxon.last_change.id
    end
  end

end
