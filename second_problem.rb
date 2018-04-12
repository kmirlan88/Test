require "selenium-webdriver"
require 'logger'


Selenium::WebDriver::Chrome.driver_path="/path/to/chromedriver"
wait = Selenium::WebDriver::Wait.new(timeout: 10)


logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S'

page_url = "https://twitter.com/"
username = "username"
password = "password"


logger.info("Test Started")

logger.info("Initializing Chrome")
driver = Selenium::WebDriver.for :chrome

logger.info("Maximizing browser window")
driver.manage.window.maximize


driver.navigate.to page_url

if driver.title.include? "It's what's happening"
	logger.info("Successfully opened #{page_url}")
else
	logger.error("Not able to open #{page_url}")
end


username_field = wait.until { driver.find_element(name: 'session[username_or_email]') }
username_field.send_keys username
logger.info("Typed #{username}")

password_field = wait.until { driver.find_element(name: 'session[password]') }
password_field.send_keys password
logger.info("Typed #{password}")

login_button = wait.until { driver.find_element(xpath: '//input[@value="Log in"]') }
login_button.click
logger.info("Clicked on Login button")

# dont have an account with twitter or facebook
# but logic is to verify that user successfully loged in by locating unique element for home page
# then post 'Hello world' and verify text present on the page


driver.quit()