# frozen_string_literal: true

require 'rails_helper'

feature "Compare revisions", %(
  As an editor of AntCat
  I want to browse previous revisions of items
  So I can see what has been changed
), :versioning do
  def i_follow_the_first_linked_history_item
    first("a[href^='/history_items/']").click
  end

  def i_add_a_history_item content
    i_click_on 'the add history item button'
    fill_in "taxt", with: content
    click_button "Save"
  end

  background do
    i_log_in_as_a_catalog_editor
  end

  scenario "Comparing history item revisions" do
    there_is_a_genus_protonym "Atta"

    # Added item.
    i_go_to 'the protonym page for "Atta"'
    i_add_a_history_item "initial content"
    i_go_to 'the activity feed'
    i_follow_the_first_linked_history_item
    i_follow "History"
    i_should_see "This item does not have any previous revisions"

    # Edited.
    HistoryItem.last.update!(taxt: "second revision content")
    i_go_to 'the activity feed'
    i_follow_the_first_linked_history_item
    i_follow "History"
    i_should_see "Current version"
    i_should_see "second revision content"
    i_should_not_see "initial content"

    i_follow "prev"
    i_should_see "Difference between revisions"
    i_should_see "initial content"

    # Deleted.
    HistoryItem.last.destroy!
    i_go_to 'the activity feed'
    i_follow_the_first "History"
    i_should_see "Version before item was deleted"
    i_should_see "second revision content"

    i_follow "cur"
    i_should_see "Difference between revisions"
    i_should_see "initial content"
  end

  scenario "Comparing reference section revisions" do
    create :reference_section, references_taxt: "test"

    i_go_to 'the page of the most recent reference section'
    i_follow "History"
    i_should_see "This item does not have any previous revisions"
  end

  scenario "Comparing revisions with intermediate revisions", :js do
    create :history_item, :taxt, taxt: "initial version"
    HistoryItem.last.update!(taxt: "second version")
    HistoryItem.last.update!(taxt: "last version")

    i_go_to 'the page of the most recent history item'
    i_follow "History"
    click_button "Compare selected revisions"
    i_should_see "second version", within: 'the left side of the diff'
    i_should_see "last version", within: 'the right side of the diff'
    i_should_not_see "initial version"

    i_follow_the_second "cur"
    i_should_see "initial version", within: 'the left side of the diff'
    i_should_see "last version", within: 'the right side of the diff'
    i_should_not_see "second version"
  end
end
