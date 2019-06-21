module ApplicationHelper
  def or_dash thing
    return dash if thing.blank? || thing.try(:zero?)
    thing
  end

  def dash
    "&ndash;".html_safe
  end

  def pluralize_with_delimiters count, singular, plural = nil
    pluralize number_with_delimiter(count), singular, plural
  end

  def add_period_if_necessary string
    return "".html_safe if string.blank?
    return string if string[-1..-1] =~ /[.!?]/
    string + '.'
  end

  def italicize string
    content_tag :i, string
  end

  def unitalicize string
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string = string.dup
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

  # TODO: See if we can use CSS only instead.
  def external_link_to label, url
    link_to label, url, class: 'external-link'
  end

  # TODO: See if we can use CSS only instead.
  def pdf_link_to label, url
    link_to label, url, class: 'pdf-link'
  end

  def activities_link_for_trackable trackable
    activities_link trackable.class.name, trackable.id
  end

  def activities_link trackable_type, trackable_id
    return unless trackable_type
    return if trackable_type.in? Activity::DEPRECARD_TRACKABLE_TYPES

    type = trackable_type.constantize.base_class
    url = activities_path(trackable_type: type, trackable_id: trackable_id)
    link_to (antcat_icon("filter") + 'Activities'), url, class: "btn-normal filter-activities-link"
  end

  def beta_label
    content_tag :span, "beta", class: "rounded-badge"
  end

  def new_label
    content_tag :span, "new!", class: "rounded-badge"
  end

  def spinner_icon
    "<span class='spinner'><i class='fa fa-refresh fa-spin'></i></span>".html_safe
  end

  # Used when more than one button can trigger the spinner.
  def shared_spinner_icon
    "<span class='shared-spinner'><i class='fa fa-refresh fa-spin'></i></span>".html_safe
  end

  def foundation_class_for flash_type
    case flash_type.to_sym
    when :notice then "primary"
    when :alert  then "alert"
    when :error  then "alert"
    else         raise "flash_type `#{flash_type}` not supported"
    end
  end

  def menu_active? menu
    first_breadcrumb = breadcrumbs.first&.key
    menu == first_breadcrumb
  end

  def inline_expandable label = "Show more"
    show_more = content_tag :a, class: "hide-when-expanded gray" do
                  content_tag :small, label
                end
    hidden = content_tag :span, class: "show-when-expanded" do
               yield
             end

    content_tag :span, class: "expandable" do
      show_more + hidden
    end
  end

  def edit_summary_text_field_tag
    text_field_tag :edit_summary, params[:edit_summary], placeholder: "Edit summary (optional)", maxlength: Activity::EDIT_SUMMARY_MAX_LENGTH
  end

  def search_icon
    antcat_icon "search"
  end

  def append_superadmin_icon label
    label.html_safe << antcat_icon("superadmin")
  end

  def append_refresh_icon label
    label.html_safe << antcat_icon("refresh")
  end

  def antcat_icon *css_classes
    content_tag :span, nil, class: ["antcat_icon"].concat(Array.wrap(css_classes))
  end
end
