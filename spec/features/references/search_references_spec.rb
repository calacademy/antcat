# frozen_string_literal: true

require 'rails_helper'

feature "Searching references" do
  scenario "Searching for an author name with diacritics, using the diacritics in the query", :search do
    this_reference_exists author: "Hölldobler, B."
    this_reference_exists author: "Fisher, B."
    i_go_to 'the references page'

    i_fill_in "reference_q", with: "Hölldobler", within: 'the desktop menu'
    i_click_on 'the reference search button'
    i_should_see "Hölldobler, B."
    i_should_not_see "Fisher, B."
  end

  scenario "Finding nothing" do
    i_go_to 'the references page'

    i_fill_in "reference_q", with: "zzzzzz", within: 'the desktop menu'
    i_click_on 'the reference search button'
    i_should_see "No results found"
  end

  scenario "Maintaining search box contents" do
    i_go_to 'the references page'

    i_fill_in "reference_q", with: "zzzzzz year:1972-1980", within: 'the desktop menu'
    i_click_on 'the reference search button'
    i_should_see "No results found"

    the_field_within_should_contain "reference_q", "#desktop-only-header", "zzzzzz year:1972-1980"
  end
end
