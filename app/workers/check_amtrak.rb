class CheckAmtrak < ActiveJob::Base
  queue_as :default

  def perform
    scraper = Scraper::Amtrak.new("BAL", "TRE", Date.parse("Nov 22"))
    p "Prices found: #{scraper.prices.map { |p| p[:price]}}"
    scraper.prices.select! { |p| p[:price] < 90 }
    scraper.prices.each do |p|
      p "Found cheap prices!"
      @client = Twilio::REST::Client.new
      @client.messages.create( from: '14435520159', to: '7326739564', body: "Cheap amtrak tix ($#{p[:price]}) for #{p[:date_time_string]}" )
    end
  end
end
