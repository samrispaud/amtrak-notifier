# require 'nokogiri'
# require 'headless'
require 'selenium-webdriver'
require 'capybara/poltergeist'

module Scraper
  class Stockfuse
    attr_reader :errors

    def initialize(user)
      begin
        @errors = []

        # Register driver
        Capybara.register_driver :poltergeist do |app|
          Capybara::Poltergeist::Driver.new(app, js_errors: false)
        end

        # Configure Capybara to use Poltergeist as the driver
        Capybara.default_driver = :poltergeist

        @driver = Capybara.current_session
        @driver.visit 'https://stockfuse.com/accounts/signin/?next=/'
        @driver.fill_in 'id_identification', with: user.email
        @driver.fill_in 'id_password', with: user.stockfuse_password
        @driver.click_on 'id_submit'
        sleep(5)
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
          @driver.execute_script("$('#order-buy').click()")
        elsif (order.order_type == "SELL")
          @driver.execute_script("$('#order-sell').click()")
        else
          raise Exception.new("Order type invalid")
        end
        sleep(1)
        # fill in ticker
        ticker = @driver.find(:xpath, "//form[@id='order-form']/div[4]/div/div/div[1]/input")
        ticker.set(order.ticker)
        sleep(2)
        # select first option in typeahead for ticker
        ticker.native.send_keys(:return)

        # set order quantity
        quantity = @driver.fill_in "order-quantity", with: order.quantity

        # fill in a comment because this is required
        order_string = "Order for #{order.quantity} shares of #{order.ticker}"
        @driver.fill_in "order-comment", with: order_string
        # submit order
        # @driver.save_screenshot 'before_trade.png'
        @driver.find(:xpath, "//div[@class='modal-footer']/button").click
        # wait for trade to send
        sleep(3)
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
