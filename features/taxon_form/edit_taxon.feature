Feature: Editing a taxon
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Changing the authorship
    Given there is a genus "Eciton"
    And there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the catalog page for "Eciton"
    Then I should not see "Formica"

    When I go to the edit page for "Eciton"
    And I pick "Formica" from the protonym selector
    And WAIT
    And I press "Save"
    Then I should see "Formica" in the headline
    And I should see "page 9 (dealate queen)" in the headline

  Scenario: Changing incertae sedis (with edit summary)
    Given there is a genus "Atta" that is incertae sedis in the subfamily

    When  I go to the catalog page for "Atta"
    Then I should see "incertae sedis in subfamily"

    When I go to the edit page for "Atta"
    And I select "(none)" from "taxon_incertae_sedis_in"
    And I fill in "edit_summary" with "fix incertae sedis"
    And I save the taxon form
    Then I should be on the catalog page for "Atta"
    And I should not see "incertae sedis in subfamily"

    When I go to the activity feed
    Then I should see "Archibald edited the genus Atta" and no other feed items
    And I should see the edit summary "fix incertae sedis"

  Scenario: Changing gender of genus-group name
    Given there is a genus "Atta" with "masculine" name

    When I go to the catalog page for "Atta"
    Then I should see "masculine"

    When I go to the edit page for "Atta"
    And I select "neuter" from "taxon_name_attributes_gender"
    And I save the taxon form
    Then I should be on the catalog page for "Atta"
    And I should see "neuter"
