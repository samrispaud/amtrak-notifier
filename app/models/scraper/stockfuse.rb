require 'nokogiri'
require 'headless'
require 'selenium-webdriver'

module Scraper
  class Stockfuse
    attr_reader :errors

    def initialize(user)
      begin
        headless = Headless.new(dimensions: "1920x1080x24")
        headless.start
        @errors = []
        @driver = Selenium::WebDriver.for :chrome
        @driver.navigate.to 'https://stockfuse.com/accounts/signin/?next=/'
        @driver.find_element(:id, "id_identification").send_keys user.email
        @driver.find_element(:id, "id_password").send_keys user.password
        @driver.find_element(:id, "id_submit").click
      rescue => e
        @errors << e
      end
    end

    def execute_order(order)
      begin
        @driver.execute_script("$('.btn-fuse-new-trade').first().click()")
        sleep(3)
        @driver.execute_script("$('.btn-fuse-new-trade').first().click()")
        @driver.find_element(:id, "order-sell").click
        ticker = @driver.find_element(:xpath, "//form[@id='order-form']/div[4]/div/div/div[1]/input")
        ticker.click
        ticker.clear
        ticker.send_keys "CMG"
        sleep(1)
        ticker.send_keys:return
        @driver.find_element(:name, "order-quantity").click
        @driver.find_element(:name, "order-quantity").clear
        @driver.find_element(:name, "order-quantity").send_keys "66"
        if not @driver.find_element(:xpath, "//form[@id='order-form']/div[7]/div[1]/select//option[1]").selected?
            @driver.find_element(:xpath, "//form[@id='order-form']/div[7]/div[1]/select//option[1]").click
        end
        @driver.find_element(:name, "order-comment").click
        @driver.find_element(:name, "order-comment").clear
        @driver.find_element(:name, "order-comment").send_keys "Trade by samrispaud"
        binding.pry
        # @driver.save_screenshot 'before_trade.png'
        @driver.find_element(:xpath, "//div[@class='modal-footer']/button").click
        sleep(10)
        # @driver.save_screenshot 'after_trade.png'
        @driver.find_element(:css, "span.underline").click
        @driver.find_element(:xpath, "//div[@class='main-sidebar-user']//a[.='Sign Out']").click
        # @driver.save_screenshot 'done.png'
        @driver.quit
        headless.destroy
      rescue => e
        @errors << e
      end
    end
  end
end
