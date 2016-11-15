class CheckAlert < ActiveJob::Base
  queue_as :default

  def perform(alert_id)
    alert = Alert.find(alert_id)
    current_price = GoogleFinance::Api.quote(alert.exchange, alert.ticker).to_f
    alert.update(last_price: current_price)
    case alert.comparison_logic
    when "GREATER THAN"
      if (current_price > alert.price)
        stockfuse = Scraper::Stockfuse.new(alert.user)
        stockfuse.execute_order(alert.order)
        if stockfuse.errors.present?
          alert.order.update(status: stockfuse.errors.join(","))
          alert.update(status: "Error")
        else
          alert.order.update(status: "Success")
          alert.update(status: "Success")
        end
      end
    when "LESS THAN"
      if (current_price < alert.price)
        stockfuse = Scraper::Stockfuse.new(alert.user)
        stockfuse.execute_order(alert.order)
        if stockfuse.errors.present?
          alert.order.update(status: stockfuse.errors.join(","))
          alert.update(status: "Error")
        else
          alert.order.update(status: "Success")
          alert.update(status: "Success")
        end
      end
    end
    # if current price LOGIC COMPARE to alert.trigger_price
  end
end
