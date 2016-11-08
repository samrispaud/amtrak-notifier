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
        @driver.find_element(:id, "id_password").send_keys user.stockfuse_password
        @driver.find_element(:id, "id_submit").click
      rescue => e
        @errors << e
      end
    end

    def execute_order(order)
      begin
        # open order modal
        @driver.execute_script("$('.btn-fuse-new-trade').first().click()")
        sleep(2)
        @driver.execute_script("$('.btn-fuse-new-trade').first().click()")
        sleep(2)

        # select game
        game_name = order.game.name
        @driver.execute_script("var textToFind = '#{game_name}'; var dd = document.getElementsByName('order-match-id')[0]; for (var i = 0; i < dd.options.length; i++) { if (dd.options[i].text === textToFind) { dd.selectedIndex = i; break; } }")
        sleep(2)

        # select order type
        if (order.order_type == "BUY")
          @driver.find_element(:id, "order-buy").click
        elsif (order.order_type == "SELL")
          @driver.find_element(:id, "order-sell").click
        else
          raise Exception.new("Order type invalid")
        end

        # fill in ticker
        ticker = @driver.find_element(:xpath, "//form[@id='order-form']/div[4]/div/div/div[1]/input")
        ticker.click
        ticker.clear
        ticker.send_keys order.ticker
        sleep(3)
        # select first option in typeahead for ticker
        ticker.send_keys:return

        # set order quantity
        quantity = @driver.find_element(:name, "order-quantity")
        quantity.click
        quantity.clear
        quantity.send_keys order.quantity

        # fill in a comment because this is required
        order_string = "Order for #{order.quantity} share #{order.ticker}"
        @driver.find_element(:name, "order-comment").click
        @driver.find_element(:name, "order-comment").clear
        @driver.find_element(:name, "order-comment").send_keys order_string

        # submit order
        # @driver.save_screenshot 'before_trade.png'
        @driver.find_element(:xpath, "//div[@class='modal-footer']/button").click
        # wait for trade to send
        sleep(5)
        logout_of_stockfuse
      rescue => e
        @errors << e
      end
    end

    # def check_order_succesful(order)
    #   begin
    #     # @driver.save_screenshot 'after_trade.png'
    #     @driver.find_element(:class, "fuse-list")
    #     @driver.find_element(:xpath, "//div[@class='main-sidebar-user']//a[.='Sign Out']").click
    #     # @driver.save_screenshot 'done.png'
    #     @driver.quit
    #     headless.destroy
    #   rescue => e
    #     @errors << e
    #   end
    # end

    def logout_of_stockfuse
      begin
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
