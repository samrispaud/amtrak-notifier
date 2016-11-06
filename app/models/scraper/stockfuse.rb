require 'nokogiri'
require 'headless'
require 'selenium-webdriver'

module Scraper
  class Stockfuse
    def self.logon
      headless = Headless.new(dimensions: "1920x1080x24")
      headless.start
      driver = Selenium::WebDriver.for :chrome

      driver.navigate.to 'https://stockfuse.com/accounts/signin/?next=/'
      driver.find_element(:id, "id_identification").click
      driver.find_element(:id, "id_identification").clear
      driver.find_element(:id, "id_identification").send_keys "samrispaud@gmail.com"
      driver.find_element(:id, "id_password").click
      driver.find_element(:id, "id_password").clear
      driver.find_element(:id, "id_password").send_keys "Samuel2015"
      driver.find_element(:id, "id_submit").click
      driver.execute_script("$('.btn-fuse-new-trade').first().click()")
      sleep(3)
      driver.find_element(:id, "order-sell").click
      ticker = driver.find_element(:xpath, "//form[@id='order-form']/div[4]/div/div/div[1]/input")
      ticker.click
      ticker.clear
      ticker.send_keys "AAPL"
      ticker.send_keys:return
      driver.sendKeys(Keys.TAB)
      driver.find_element(:name, "order-quantity").click
      driver.find_element(:name, "order-quantity").clear
      driver.find_element(:name, "order-quantity").send_keys "23"
      if not driver.find_element(:xpath, "//form[@id='order-form']/div[7]/div[1]/select//option[1]").selected?
          driver.find_element(:xpath, "//form[@id='order-form']/div[7]/div[1]/select//option[1]").click
      end
      driver.find_element(:name, "order-comment").click
      driver.find_element(:name, "order-comment").clear
      driver.find_element(:name, "order-comment").send_keys "Trade by samrispaud"
      binding.pry
      driver.save_screenshot 'before_trade.png'
      driver.find_element(:xpath, "//div[@class='modal-footer']/button").click
      sleep(10)
      driver.save_screenshot 'after_trade.png'
      driver.find_element(:css, "span.underline").click
      driver.find_element(:xpath, "//div[@class='main-sidebar-user']//a[.='Sign Out']").click
      driver.save_screenshot 'done.png'
      driver.quit
      headless.destroy


      return headless, driver
    end
  end
end
