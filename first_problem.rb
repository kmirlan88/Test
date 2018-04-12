require "selenium-webdriver"
require 'logger'
require 'test/unit'

extend Test::Unit::Assertions

Selenium::WebDriver::Chrome.driver_path="/path/to/chromedriver"
wait = Selenium::WebDriver::Wait.new(timeout: 10)


logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S'

page_url = "https://rubygems.org/"
search_gem = "ruby-debug19"

logger.info("Test Started")

logger.info("Initializing Chrome")
driver = Selenium::WebDriver.for :chrome

logger.info("Maximizing browser window")
driver.manage.window.maximize


driver.navigate.to page_url

if driver.title.include? "gem host"
	logger.info("Successfully opened #{page_url}")
else
	logger.error("Not able to open #{page_url}")
end


search_field_el = wait.until { driver.find_element(id: "home_query") }
logger.info("Found search field")

logger.info("Searching for '#{search_gem}'")
search_field_el.send_keys search_gem
search_field_el.submit


first_match_result_el = wait.until { driver.find_element(xpath: "//h2[contains(text(), #{search_gem})]") }
logger.info("Clicking on first exact match result")
first_match_result_el.click


runtime_dependencies_el = wait.until { driver.find_element(id: "runtime_dependencies") }
deps = runtime_dependencies_el.text
logger.info("Runtime dependencies: \n#{deps}")


#just a custom verify logic in order to test if expected text is there
begin
	assert_match /columnize/, deps
	assert_match /linecache19/, deps
	assert_match /ruby-debug-base19/, deps
	logger.info("Dependencies PASS")
rescue
	logger.error("Dependencies FAIL")
end


authors_el = driver.find_element(xpath: "//div[@class='gem__members']/ul")
authors = authors_el.text
logger.info("Names of the authors: \n#{authors}")

begin
	assert_match /Sibilev/, authors
	assert_match /Moseley/, authors
	logger.info("Authors PASS")
rescue
	logger.error("Authors FAIL")
end

driver.quit
