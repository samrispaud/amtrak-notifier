class CheckAlert < ActiveJob::Base
  queue_as :check_alert

  def perform(alert_id)
    alert = Alert.find(alert_id)
    current_price = GoogleFinance::Api.quote(alert.exchange, alert.ticker)
    # if current price LOGIC COMPARE to alert.trigger_price


  end
end
