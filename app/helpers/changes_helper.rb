module ChangesHelper
  def confirm_before_undo_button change
    return unless can? :edit, :catalog
    link_to 'Undo...', change_undos_path(change), class: "btn-warning btn-tiny"
  end

  def approve_all_changes_button
    return unless user_is_superadmin?

    link_to 'Approve all', approve_all_changes_path,
      method: :put, class: "btn-warning",
      data: { confirm: "Are you sure you want to approve all changes?" }
  end

  def changes_subnavigation_links
    [
      link_to('All Changes', changes_path),
      link_to('Unreviewed Changes', unreviewed_changes_path)
    ]
  end

  # TODO copy-pasted from `ChangesDecorator`.
  def format_change_type_verb change_type
    case change_type
    when "create" then "added"
    when "delete" then "deleted"
    else               "changed"
    end
  end
end
