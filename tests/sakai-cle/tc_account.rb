# 
# == Synopsis
#
# Tests user account modification, including first and last name
# changes, and updates to the password
#
# Author: Abe Heward (aheward@rSmart.com)
gem "test-unit"
require "test/unit"
require 'sakai-cle-test-api'
require 'yaml'

class UserAccountUpdate < Test::Unit::TestCase
  
  include Utilities

  def setup
    # Get the test configuration data
    @config = YAML.load_file("config.yml")
    @directory = YAML.load_file("directory.yml")
    @sakai = SakaiCLE.new(@config['browser'], @config['url'])
    @browser = @sakai.browser
    @login_page = @sakai.page
    # This test case requires logging in as a student
    per = @directory['person9']
    @user_name = per['id']
    @user_first = per['firstname']
    @user_last = per['lastname']
    @password = per['password']
    
    # Test case data
    @first_name = random_nicelink(99)
    @last_name = random_nicelink(99)
    @email_address = "a#{random_nicelink(20)}a@a#{random_nicelink(20)}.com"
    @new_password = random_string(32)
    
    # Validation text -- These contain page content that will be used for
    # test asserts.
    @invalid_email_alert = "Alert: The email address is invalid"
    @unmatched_passwords = "Alert: Please enter the password the same in both fields."
    @need_orig_pw = "Alert: Please enter your correct current password." # Note that this text is obviously bad. Needs a JIRA.
    
  end
  
  def teardown
    # Close the browser window
    @browser.close
  end
  
  def test_user_update
    
    # Log in to Sakai
    workspace = @login_page.login(@user_name, @password)
    
    account = workspace.account
    
    # TEST CASE: Verify user id
    assert_equal account.user_id, @user_name
    
    # Edit User
    edit_account = account.modify_details
    
    # Blank out name and email fields
    edit_account.first_name=""
    edit_account.last_name=""
    edit_account.email=""
    
    account = edit_account.update_details
    
    # TEST CASE: verify can save with null values
    assert_equal account.first_name, ""
    
    # Change email field
    edit_account = account.update_details
    
    # Test an invalid email address
    edit_account.email="blablabla"
    edit_account.update_details
    
    # TEST CASE: Verify alert about invalid email address
    assert @browser.text.include?(@invalid_email_alert), "No warning about invalid email address"
    
    edit_account.email=@email_address
    
    # Create unmatched passwords (check for case-sensitivity)
    edit_account.create_new_password="aBcd1234$"
    edit_account.verify_new_password="aBcd1234$"
    edit_account = edit_account.update_details
    # TEST CASE: Verify original password must be added
    assert @browser.text.include?(@need_orig_pw), "No warning about needing current password"
    
    edit_account.current_password=@password
    edit_account.create_new_password="aBcd1234$"
    edit_account.verify_new_password="Abcd1234$"
    edit_account = edit_account.update_details
    
    # TEST CASE: Verify alert about unmatched passwords
    assert @browser.text.include?(@unmatched_passwords), "No warning about unmatched passwords"
    
    # Set names. Set password values the same and save changes
    edit_account.first_name=@first_name
    edit_account.last_name=@last_name
    edit_account.current_password=@password
    edit_account.create_new_password=@new_password
    edit_account.verify_new_password=@new_password
    
    account = edit_account.update_details

    # TEST CASE: verify successful changes
    assert_equal @last_name, account.last_name, "Problem with last name"
    assert_equal @first_name, account.first_name, "Problem with first name"
    assert_equal @email_address, account.email, "Problem with email address"
    assert_equal account.modified, make_date(Time.now) #.utc)
    
    # Log out and log back in with new password credentials
    home = account.home
    home.logout
    
    workspace = @sakai.page.login(@user_name, @new_password)
    
    # TEST CASE: Verify the user successfully logged in
    assert @browser.link(:text, "Logout").exist?, "User was unable to log in with new password"
    
    # Reset the user's name and password to the stored values for test repeatability...
    account = workspace.account
    
    edit_account = account.modify_details
    edit_account.first_name=@user_first
    edit_account.last_name=@user_last
    edit_account.current_password=@new_password
    edit_account.create_new_password=@password
    edit_account.verify_new_password=@password
    edit_account.update_details
    
  end
  
end
