@javascript @editing
Feature: Taxt edit box

  Scenario: Inserting a reference
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Reference"

  Scenario: Inserting a taxon
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Taxon"

  Scenario: Cancelling while choosing the tag type
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    Then I should see "{Inserting...}"
    And I press "Cancel"
    Then I should not see "{Inserting...}"
