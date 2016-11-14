require 'httparty'

module GoogleFinance
  class Api
    attr_reader :errors

    # http://finance.google.com/finance/info?client=ig&q=NASDAQ:GOOG
    # {
    #   "id"=>"304466804484872",
    #   "t"=>"GOOG",
    #   "e"=>"NASDAQ",
    #   "l"=>"754.02",
    #   "l_fix"=>"754.02",
    #   "l_cur"=>"754.02",
    #   "s"=>"0",
    #   "ltt"=>"4:00PM EST",
    #   "lt"=>"Nov 11, 4:00PM EST",
    #   "lt_dts"=>"2016-11-11T16:00:02Z",
    #   "c"=>"-8.54",
    #   "c_fix"=>"-8.54",
    #   "cp"=>"-1.12",
    #   "cp_fix"=>"-1.12",
    #   "ccol"=>"chr",
    #   "pcls_fix"=>"762.56"
    # }

    def self.quote(exchange, ticker)
      begin
        response = HTTParty.get("http://finance.google.com/finance/info?client=ig&q=#{exchange}:#{ticker}")
        response = response[0] + response[3..-1]
        JSON.parse(response)[0]["l"]
      rescue => e
        @errors << e
      end
    end
  end
end
