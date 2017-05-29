require 'capybara/poltergeist'

module Scraper
  class Amtrak
    attr_reader :errors

    def initialize
      begin
        @errors = []

        # Register driver
        Capybara.register_driver :poltergeist do |app|
          Capybara::Poltergeist::Driver.new(app, js_errors: false)
        end

        # Configure Capybara to use Poltergeist as the driver
        Capybara.default_driver = :poltergeist
        Capybara.save_path = "public/capybara_screenshots/"

        @driver = Capybara.current_session
        @driver.visit 'https://www.amtrak.com/home'
        check_tickets
      rescue => e
        @errors << e
      end
    end

    def check_tickets
      begin
        # Fill out DEPARTING station
        departs = @driver.find(:id, "departs")
        departs.send_keys "bal"
        sleep(1)
        # select first option in typeahead
        departs.native.send_keys(:return)

        # Fill out ARRIVAL station
        departs = @driver.find(:id, "arrives")
        departs.send_keys "nyp"
        sleep(1)
        # select first option in typeahead
        departs.native.send_keys(:return)

        # Fill out date
        date_this_month = '31'
        @driver.execute_script("document.getElementById('wdfdate1').click()")
        @driver.execute_script("var aTags = document.getElementsByTagName('a'); var date = #{date_this_month}; for (var i = 0; i < aTags.length; i++) { if (aTags[i].textContent == date) { aTags[i].click(); break; } }")

        # Select time, afternoon
        @driver.select "Evening", from: "wdftime1"

        # submit
        @driver.execute_script("document.getElementById('findtrains').click()")
        sleep(2)

        # parse
        html_doc = Nokogiri::HTML(@driver.html)
        prices = html_doc.xpath("//tr[@class='ffam-segment-container']//td[1]//div[1]//span[@id='_lowestFareFFBean']")
        parsed_prices = prices.map { |p| p.content.to_f }
        cheap_prices = parsed_prices.any? { |p| p < 50 }
        logger.debug "Amtrak Scraper found prices #{parsed_prices} for date #{date_this_month}"
        p "Amtrak Scraper found prices #{parsed_prices} for date #{date_this_month}"
        if cheap_prices
          @client = Twilio::REST::Client.new
          @client.messages.create( from: '14435520159', to: '7326739564', body: "Cheap amtrak tix found for 05/31" )
        end
      rescue => e
        @errors << e
      end
    end
  end
end
