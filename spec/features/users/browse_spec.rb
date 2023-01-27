# frozen_string_literal: true

require 'rails_helper'

feature "Browse" do
  def batiatus_has_commented_cool_on_an_issue_with_the_title_typos
    issue = create :issue, title: "Typos"
    user = User.find_by!(name: "Batiatus")
    Comment.build_comment(issue, user, body: "Cool").save!
  end

  background do
    i_log_in_as_a_catalog_editor_named "Batiatus"
  end

  scenario "Visiting a user's page" do
    create :user, email: "quintus@antcat.org", name: "Quintus"

    i_go_to 'the users page'
    i_follow "Quintus"
    i_should_see "Name: Quintus"
    i_should_see "Email: quintus@antcat.org"
    i_should_see "Quintus's most recent activity"
    i_should_see "No activities"
    i_should_see "Quintus's most recent comments"
    i_should_see "No comments"
  end

  scenario "See user's most recent feed activities" do
    there_is_a_journal_activity_by "destroy", "Batiatus"

    i_go_to 'the user page for "Batiatus"'
    i_should_see "Batiatus's most recent activity"
    i_should_see "Batiatus deleted the journal", within: 'the activity feed'
  end

  scenario "See user's most recent comments" do
    batiatus_has_commented_cool_on_an_issue_with_the_title_typos

    i_go_to 'the user page for "Batiatus"'
    i_should_see "Batiatus's most recent comments"
    i_should_see "Batiatus commented on the issue Typos:"
  end
end
