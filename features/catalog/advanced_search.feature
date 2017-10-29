Feature: Searching the catalog
  As a user of AntCat
  I want to search the catalog in index view
  So that I can find taxa with their parents and siblings

  Background:
    Given I go to the catalog
    And I follow the first "Advanced Search"

  Scenario: Searching when no results
    When I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching when one result
    Given there is a species described in 2010
    And there is a species described in 2011

    When I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Searching for subfamilies
    Given there is a subfamily described in 2010

    When I select "Subfamilies" from the rank selector
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Searching for an invalid taxon
    Given there is an invalid species described in 2010

    When I fill in "year" with "2010"
    And I check valid only in the advanced search form
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching for an author's descriptions
    Given there is a species described in 2010 by "Bolton"

    When I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Finding a genus
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Ophthalmopone major" with genus "Ophthalmopone"

    When I fill in "genus" with "Atta"
    And I press "Go" in the search section
    Then I should see "Atta major"

  Scenario: Manually entering an unknown name instead of using picklist
    Given there is a species described in 2010 by "Bolton, B."

    When I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "No results found. If you're choosing an author, make sure you pick the name from the dropdown list."

  Scenario: Searching for locality
    Given there is a genus located in "Africa"
    And there is a genus located in "Zimbabwe"

    When I fill in "locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within the search results

  Scenario: Searching for biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region "Afrotropic"

    When I select "Afrotropic" from the biogeographic region selector
    And I press "Go" in the search section
    Then I should see "2 results"
    And I should see "Afrotropic" within the search results

  Scenario: Searching for 'Any' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a genus located in "Africa"

    When I select "Any" from the biogeographic region selector
    And I fill in "locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Searching for 'None' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species located in "Africa"

    When I select "Species" from the rank selector
    And I select "None" from the biogeographic region selector
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within the search results

  Scenario: Searching for a form
    Given there is a species with forms "w.q."
    And there is a species with forms "q."

    When I fill in "forms" with "w."
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "w." within the search results

  Scenario: Searching for 'described in' (range)
    Given there is a species described in 2010
    And there is a species described in 2011
    And there is a species described in 2012

    When I fill in "year" with "2010-2011"
    And I press "Go" in the search section
    Then I should see "2 result"
    And I should see the species described in 2010
    And I should see the species described in 2011

  Scenario: Searching for 'described in' (malformatted range)
    Given there is a species described in 2010
    And there is a species described in 2011

    When I fill in "year" with "2000-1900"
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Download search results
    Given there is a species described in 2010

    When I fill in "year" with "2010"
    And I press "Go" in the search section
    And I follow "Download (advanced search only)"
    Then I should get a download with the filename "all-2010.txt"
