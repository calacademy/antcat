@dormant
Feature: Editing a user
  As a user of AntCat
  I want to edit my password and email
  So that I can use a password that makes sense
    And so I can use a different email than what I was signed up with

  Scenario: Changing my password
    Given I am logged in
    When I go to the main page
    And I follow "Mark Wilden"
    Then I should be on the edit user page
    When I fill in "user_password" with "new password" within "#page_contents"
    And I fill in "user_password_confirmation" with "new password" within "#page_contents"
    And I fill in "user_current_password" with "secret" within "#page_contents"
    And I press "Save"
    Then I should be on the main page
    And I should see "Your account has been updated"
  #Scenario: Logging in with changed password
    When I follow "Logout"
    Then I should not see "Mark Wilden"
    When I follow "Login"
    And I fill in the email field with my email address
    And I fill in "user_password" with "new password"
    And I press "Go" within "#login"
    Then I should be on the main page
    And I should see "Mark Wilden"

  Scenario: Changing my user name
    Given I am logged in
    When I go to the main page
    Then I should see "Mark Wilden"
    And I should not see "Brian Fisher"
    When I follow "Mark Wilden"
    And I fill in "user_name" with "Brian Fisher" within "#page_contents"
    And I fill in "user_current_password" with "secret" within "#page_contents"
    And I press "Save"
    Then I should be on the main page
    And I should see "Brian Fisher"
    And I should not see "Mark Wilden"

  Scenario: Users can login
    Given I am logged in
    When I go to the main page
    Then I should see "Logout"

  Scenario: Superadmins can login
    Given I log in as a superadmin
    When I go to the main page
    Then I should see "Logout"

  Scenario: Superadmins should have access to active admin pages
    Given I log in as a superadmin
    When I go to the main page
    Then I should see "Admin"

  Scenario: regular users should have access to active admin pages
    Given I am logged in
    When I go to the main page
    Then I should not see "Admin"

  Scenario: Admins to be able to go to the active admin pages
    Given I log in as a superadmin
    When I go to the main page
    Then I should see "Admin"
    When I follow "Admin"
    Then I should see "Dashboard"

  Scenario: When admins logout, it should redirect to AntCat root
    Given I log in as a superadmin
    When I go to the main page
    When I follow "Admin"
    Then I should see "Dashboard"
    When I follow "Logout"
    Then I should see "An Online Catalog of the Ants of the World"

  Scenario: Non-admins should be bounced from admin pages to AntCat root
    Given I am logged in
    When I go to the useradmin page
    Then I should be on the main page

  Scenario: Admins can see the user admin page
    Given I log in as a superadmin
    When I go to the useradmin page
    Then I should be on the useradmin page

