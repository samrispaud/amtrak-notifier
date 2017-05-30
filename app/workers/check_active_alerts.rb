# get all alerts with a status of active
# for each grab the ticker and exchange and get stock price
# see if price matches order criteria
# if it does place order by calling Stockfuse scraper
# if it doesn't go to next one

class CheckActiveAlerts < ActiveJob::Base
  queue_as :default

  def perform
    # Alert.where(status: "active").find_each do |alert|
    #   CheckAlert.perform_now(alert.id)
    # end
  end
end
