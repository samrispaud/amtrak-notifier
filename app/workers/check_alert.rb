class CheckAlert < ActiveJob::Base
  queue_as :default

  def perform(alert_id)
    alert = Alert.find(alert_id)
    current_price = GoogleFinance::Api.quote(alert.exchange, alert.ticker).to_f
    alert.update(last_price: current_price)
    msg = "#{alert.order.order_type} #{alert.order.quantity} shares of #{alert.order.ticker} ($#{alert.last_price} #{alert.comparison_logic} $#{alert.price})"
    case alert.comparison_logic
    when "GREATER THAN"
      if (current_price > alert.price)
        stockfuse = Scraper::Stockfuse.new(alert.user)
        stockfuse.execute_order(alert.order)
        if stockfuse.errors.present?
          alert.order.update(status: stockfuse.errors.join(","))
          alert.update(status: "Error")
          msg = "[ERROR] " + msg
          @client = Twilio::REST::Client.new
          @client.messages.create( from: ENV["TWILIO_NUMBER"], to: alert.user.phone_number, body: msg )
        else
          alert.order.update(status: "Success")
          alert.update(status: "Success")
          game_id = alert.order.game_id
          Alert.where(ticker: alert.ticker, status: "active").joins(:order).where(orders: { game_id:  game_id }).update_all(status:"Inactivated due to similar alert succeeding")
          msg = "[SUCCESS] " + msg
          @client = Twilio::REST::Client.new
          @client.messages.create( from: ENV["TWILIO_NUMBER"], to: alert.user.phone_number, body: msg )
        end
      end
    when "LESS THAN"
      if (current_price < alert.price)
        stockfuse = Scraper::Stockfuse.new(alert.user)
        stockfuse.execute_order(alert.order)
        if stockfuse.errors.present?
          alert.order.update(status: stockfuse.errors.join(","))
          alert.update(status: "Error")
          msg = "[ERROR] " + msg
          @client = Twilio::REST::Client.new
          @client.messages.create( from: ENV["TWILIO_NUMBER"], to: alert.user.phone_number, body: msg )
        else
          alert.order.update(status: "Success")
          alert.update(status: "Success")
          game_id = alert.order.game_id
          Alert.where(ticker: alert.ticker, status: "active").joins(:order).where(orders: { game_id:  game_id }).update_all(status:"Inactivated due to similar alert succeeding")
          msg = "[SUCCESS] " + msg
          @client = Twilio::REST::Client.new
          @client.messages.create( from: ENV["TWILIO_NUMBER"], to: alert.user.phone_number, body: msg )
        end
      end
    end
  end
end
