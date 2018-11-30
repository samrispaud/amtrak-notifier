require 'capybara/poltergeist'

module Scraper
  class Amtrak
    attr_reader :prices, :error

    def initialize(departure_station, arrival_station, date)
      begin
        @departure_station = departure_station
        @arrival_station = arrival_station
        @date = date
        @day = validate_date_and_return_day_number(@date)

        @driver = register_driver

        @prices = check_tickets
      rescue => error
        p "Amtrak::Scraper Error: #{error}"
        @error = error
      end
    end

    def register_driver
      # Register driver
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, js_errors: false)
      end

      # Configure Capybara to use Poltergeist as the driver
      Capybara.default_driver = :selenium
      Capybara.save_path = "public/capybara_screenshots/"

      Capybara.current_session
    end

    def check_tickets
      begin
        p "Checking Amtrak tickets..."
        @driver.visit 'https://www.amtrak.com/home'
        sleep(4)
        # Fill out DEPARTING station
        departs = @driver.find('input[data-automation-id="fStation"]')
        departs.send_keys @departure_station
        sleep(1)
        # select first option in typeahead
        departs.native.send_keys(:return)

        # Fill out ARRIVAL station
        departs = @driver.find('input[data-automation-id="tStation"]')
        departs.send_keys @arrival_station
        sleep(1)
        # select first option in typeahead
        departs.native.send_keys(:return)

        # Fill out date
        @driver.execute_script("document.querySelectorAll(\"[data-julie='departdisplay_booking_oneway']\")[0].click()")
        @driver.execute_script("document.getElementsByClassName(\"k-in-month k-active k-today currentDate\")[5].click()")

        # Select time, doesnt really matter because all times are present in the DOM anyway
        @driver.execute_script("document.querySelectorAll(\"[data-julie='travelersnumber']\")[0].click()")
        @driver.execute_script("document.querySelectorAll(\"[data-julie='passengersdone']\")[0].click()")
        binding.pry
        # submit
        @driver.execute_script("document.querySelectorAll(\"[data-julie='findtrains']\")[0].click()")
        sleep(4)

        # parse
        p "Parsing HTML doc..."
        p @driver.html
        parse_prices(@driver.html)
      rescue => e
        p "[ERROR] An err occured: #{e}"
      end
    end

    private

    def parse_prices(html_string)
      html_doc = Nokogiri::HTML(html_string)
      train_nodes = html_doc.xpath("//div[@class='ffam-inner-wrapper']")
      train_nodes.map do |train|
        time = train.xpath("div[@class='ffam-time']").text()
        {
          price: train.xpath("span[@id='_lowestFareFFBean']").text().to_f,
          date_time_string: @date.strftime('%A %B %d ') + time
        }
      end
    end

    def validate_date_and_return_day_number(date)
      date_valid = Date.yesterday < date && date < Date.today + 1.months
      if date_valid
        date.day
      else
        throw "Invalid date"
      end
    end
  end
end
