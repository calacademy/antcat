# From Formatters::ReferenceFormatter:
# Note; this references ReferenceFormatterCache.
# Most of these routines are only hit if there's a change in the content, at which
# point it's reformatted and saved in references::formatted_cache.

class ReferenceDecorator < Draper::Decorator
  delegate_all
  include ERB::Util

  #def title
  #  format_italics h reference.title
  #end

  def created_at
    format_timestamp reference.created_at
  end

  def updated_at
    format_timestamp reference.updated_at
  end

  def public_notes
    format_italics h reference.public_notes
  end

  def editor_notes
    format_italics h reference.editor_notes
  end

  def taxonomic_notes
    format_italics h reference.taxonomic_notes
  end

  def format_reference_document_link
    doi = format_doi_link

    if reference.downloadable_by? get_current_user
      pdf = helpers.link 'PDF', reference.url, class: 'document_link'
    end

    if doi
      return doi + " " + pdf #pdf may not be defined at this poit TODO fix
    else
      return pdf
    end
  end

  def format_authorship_html
    content = format_authorship
    title = format
    helpers.content_tag(:span, title: title) { content }
  end

  def format_authorship
    reference.key.to_s
  end

  def format_italics string
    return unless string
    raise "Can't call format_italics on an unsafe string" unless string.html_safe?
    string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
    string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
    string.html_safe
  end

  def format_review_state
    review_state = reference.review_state
    return 'Being reviewed' if review_state == 'reviewing'
    return '' if review_state == 'none'
    review_state.present? ? review_state.capitalize : ''
  end

  def make_html_safe string
    string = string.dup
    quote_code = 'xdjvs4'
    begin_italics_code = '2rjsd4'
    end_italics_code = '1rjsd4'
    string.gsub! '<i>', begin_italics_code
    string.gsub! '</i>', end_italics_code
    string.gsub! '"', quote_code
    string = h string
    string.gsub! quote_code, '"'
    string.gsub! end_italics_code, '</i>'
    string.gsub! begin_italics_code, '<i>'
    string.html_safe
  end

  # See header note about cache
  def format
    string = ReferenceFormatterCache.instance.get reference, :formatted_cache
    return string.html_safe if string
    string = format!
    ReferenceFormatterCache.instance.set reference, string, :formatted_cache
    string
  end

  # See header note about cache
  def format!
    string = format_author_names.dup
    string << ' ' unless string.empty?
    string << format_year << '. '
    string << format_title << ' '
    string << format_citation
    string << " [#{format_date(reference.date)}]" if reference.date?
    string
  end

  def format_author_names
    make_html_safe reference.author_names_string
  end

  def format_year
    make_html_safe reference.citation_year if reference.citation_year?
  end

  def format_title
    format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
  end

  def format_inline_citation options = {}
    user = options.delete :user
    user ||= get_current_user
    # cache/decache under same conditions
    using_cache = user.present?
    if using_cache
      string = ReferenceFormatterCache.instance.get reference, :inline_citation_cache
      return string.html_safe if string
    end

    string = format_inline_citation! options

    if using_cache
      ReferenceFormatterCache.instance.set reference, string, :inline_citation_cache
    end

    string
  end

  def format_inline_citation! options = {}
    user = options.delete :user
    user ||= get_current_user
    reference.key.to_link user, options
  end

  def format_inline_citation_without_links
    reference.key.to_s
  end

  private
    def get_current_user
      helpers.current_user
      rescue NoMethodError
        nil
    end

    def format_timestamp timestamp
      timestamp.strftime '%Y-%m-%d'
    end

    def format_date input
      date = input
      return date if input.length < 4

      match = input.match(/(.*?)(\d{4,8})(.*)/)
      prefix = match[1]
      input = match[2]
      input = match[2]
      suffix = match[3]

      date = input[0, 4]
      return prefix + date + suffix if input.length < 6
      date << '-' << input[4, 2]
      return prefix + date + suffix if input.length < 8
      date << '-' << input[6, 2]
      h prefix + date + suffix
    end

    def format_doi_link
      unless reference.doi.nil? or reference.doi.length == 0
        helpers.link reference.doi, create_link_from_doi(reference.doi), class: 'document_link'
      end
    end

    # transform "10.11646/zootaxa.4029.1.1"
    # http://dx.doi.org/10.11646/zootaxa.4029.1.1
    def create_link_from_doi doi
      #"<a href=\"http://dx.doi.org/" + doi + "\">#{doi}</a>"
      "http://dx.doi.org/" + doi
    end
end
