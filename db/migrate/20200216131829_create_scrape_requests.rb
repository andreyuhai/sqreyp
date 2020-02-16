class CreateScrapeRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_requests do |t|
      t.string :email

      t.timestamps
    end
  end
end
