class CheckAmtrak < ActiveJob::Base
  queue_as :default

  def perform
    Scraper::Amtrak.new("3")
  end
end
