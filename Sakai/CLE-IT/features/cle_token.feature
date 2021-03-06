Feature: Token generation
  @create_user
  Scenario: Successful new user creation by admin
    Given I am logged in as admin
    Then I should see a valid session id returned
    When I create a new user
    Then I should see a valid user id returned

  Scenario: Successful new user login
    Given I am logged in as new user
    Then I should see a valid session id returned for the new user

  Scenario: Successful new auth token generation
    Given I am logged in as admin
    And I request a new auth token
    Then I should see a new auth token

  @delete_user
  Scenario: Successful user deletion
    Given I am logged in as admin
    Then I should see a valid session id returned
    When I delete a user
    Then I should see a success confirmation

  @admin_signout
  Scenario: Successfully sign out admin user
    Given I am logged in as admin
    When I sign out as admin
    Then I should see a success code
