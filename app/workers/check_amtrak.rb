class CheckAmtrak < ActiveJob::Base
  queue_as :default

  def perform
    Scraper::Amtrak.new()
  end
end
