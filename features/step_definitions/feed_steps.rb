Given(/^activity tracking is (enabled|disabled)$/) do |state|
  new_state = case state
              when "enabled"  then true
              when "disabled" then false
              else raise
              end
  Feed.enabled = new_state
end

Given("there is an activity with the edit summary {string}") do |edit_summary|
  create :activity, :custom, edit_summary: edit_summary
end

Given("there is an automated activity with the edit summary {string}") do |edit_summary|
  create :activity, :custom, edit_summary: edit_summary, automated_edit: true
end

Then("I should see {string} and no other feed items") do |text|
  step %(I should see "#{text}")
  step "I should see 1 item in the feed"
end

Then("I should see {int} item(s) in the feed") do |expected_count|
  expect(feed_items_count).to eq expected_count.to_i
end

Then("I should see at least {int} item(s) in the feed") do |expected_count|
  expect(feed_items_count).to be >= expected_count.to_i
end

def feed_items_count
  all("table.activities > tbody tr").size
end

When("I hover the first activity item") do
  find("table.activities > tbody > tr:first-of-type").hover
end

Then("I should see the edit summary {string}") do |content|
  within "table.activities" do
    step %(I should see "#{content}")
  end
end

# Journal
Given("there is a {string} journal activity") do |action|
  cheat_and_set_user_for_feed
  journal = create :journal, name: "Archibald Bulletin"
  journal.create_activity action.to_sym
end

# Taxon
When("I add a taxon for the feed") do
  Feed.without_tracking do
    cheat_and_set_user_for_feed
    create :subfamily, name: create(:subfamily_name, name: "Antcatinae"),
      family: create(:family)
  end
end

# ReferenceSection
When("I add a reference section for the feed") do
  reference_section = Feed.without_tracking do
    ReferenceSection.create title_taxt: "PALAEONTOLOGY",
    references_taxt: "The Ants (amber checklist)", taxon: create(:family)
  end

  cheat_and_set_user_for_feed
  reference_section.create_activity :create
end

When("I click on Show more") do
  find("a", text: "Show more").click
end

Given("the activities are paginated with {int} per page") do |per_page|
  Activity.per_page = per_page.to_i
end

Given("there are {int} activity items") do |number|
  number.to_i.times { create :activity }
end

Then(/^the query string should (not )?contain "([^"]*)"$/) do |should_not, contain|
  match = page.current_url[contain]
  if should_not
    expect(match).to be nil
  else
    expect(match).to be_truthy
  end
end

# When JavaScript is enabled, Cucumber and the factories run in different threads,
# so it's tricky to access the request which is where the feed get's the current user,
# and `UndoTracker` gets the `current_change_id`.
#
# TODO: Many specs and steps cheat to make life easier, and that OK as long as the
# code works as intended and there are tests that doesn't cheat, but we should
# figure out how to improve this.
def cheat_and_set_user_for_feed
  User.current = User.last
end
