class ScrapeResult < ApplicationRecord
  belongs_to :scrape_request
  has_one_attached :file
end
