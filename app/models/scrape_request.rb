class ScrapeRequest < ApplicationRecord
  has_one_attached :file
  has_one :scrape_result
end
