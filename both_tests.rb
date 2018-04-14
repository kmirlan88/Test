require "selenium-webdriver"
require 'logger'
require 'rspec'


# chromedriver path
Selenium::WebDriver::Chrome.driver_path="/Users/kai/Documents/chromedriver"
# timeout = 10 sec
wait = Selenium::WebDriver::Wait.new(timeout: 10)

# logging format
logger = Logger.new(STDOUT)
logger.datetime_format = '%Y-%m-%d %H:%M:%S'


describe "Test" do

	before(:all) do
		logger.info("Initializing Chrome")
		@driver = Selenium::WebDriver.for :chrome

		logger.info("Maximizing browser window")
		@driver.manage.window.maximize
	end

	before(:each) do
		logger.info("Test Started")
	end

	after(:all) do
		sleep(4)
		@driver.quit
	end

	it "Search for gem then print dependencies and authors" do
		# page to open
		page_url = "https://rubygems.org/"
		# gem to search
		search_gem = "ruby-debug19"

		@driver.navigate.to page_url
		expect(@driver.title).to include("gem host")
		search_field_el = wait.until { @driver.find_element(id: "home_query") }
		logger.info("Found search field")

		logger.info("Searching for '#{search_gem}'")
		search_field_el.send_keys search_gem
		search_field_el.submit


		first_match_result_el = wait.until { @driver.find_element(xpath: "//h2[contains(text(), #{search_gem})]") }
		logger.info("Clicking on first exact match result")
		first_match_result_el.click


		runtime_dependencies_el = wait.until { @driver.find_element(id: "runtime_dependencies") }
		deps = runtime_dependencies_el.text
		logger.info("Runtime dependencies: \n#{deps}")


		authors_el = @driver.find_element(xpath: "//div[@class='gem__members']/ul")
		authors = authors_el.text
		logger.info("Names of the authors: \n#{authors}")

		# expected text on the current page
		expect(@driver.page_source).to include("columnize")
		expect(@driver.page_source).to include("linecache19")
		expect(@driver.page_source).to include("ruby-debug-base19")
		expect(@driver.page_source).to include("Sibilev")
		expect(@driver.page_source).to include("Moseley")

	end

	it "Post a tweet 'Hello World!'" do
		page_url = "https://twitter.com/"
		username = "pycharmce"
		password = "yesican"

		current_time = Time.now

		tweet = "Hello World! " + current_time.inspect

		@driver.navigate.to page_url
		expect(@driver.title).to include("It's what's happening")

		username_field = wait.until { @driver.find_element(name: 'session[username_or_email]') }
		username_field.send_keys username
		logger.info("Typed #{username}")

		password_field = wait.until { @driver.find_element(name: 'session[password]') }
		password_field.send_keys password
		logger.info("Typed #{password}")

		login_button = wait.until { @driver.find_element(xpath: '//input[@value="Log in"]') }
		login_button.click
		logger.info("Clicked on Login button")

		# making sure user logged in by looking up 'user settings button'
		expect(@driver.find_element(id: 'user-dropdown').displayed?).to be_truthy
		logger.info("Sucessfully Loged In")
		
		tweet_box = @driver.find_element(id: "tweet-box-home-timeline")
		tweet_box.send_keys tweet
		logger.info("Tweeted '#{tweet}'")

		tweet_btn = @driver.find_element(css: "button.tweet-action.EdgeButton.EdgeButton--primary.js-tweet-btn")
		tweet_btn.click

		# wait 1 sec for tweet to show up on stream
		sleep(1)

		# get last tweet from stream
		last_tweet = @driver.find_elements(xpath: "//ol[@id='stream-items-id']/li")[0]

		# verify your new tweet has been posted and its timing is 'now' to make sure its current
		expect(last_tweet.text).to include(tweet)
		expect(last_tweet.text).to include("now")

	end

end
