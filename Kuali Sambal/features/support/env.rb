$: << File.dirname(__FILE__)+'/../../lib'

#require 'utilities'
require 'sambal'

World PageHelper
World Utilities
World Workflows

browser = Watir::Browser.new

Before do
  @browser = browser
end

at_exit { browser.close }