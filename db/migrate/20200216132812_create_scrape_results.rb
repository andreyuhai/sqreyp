class CreateScrapeResults < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_results do |t|
      t.references :scrape_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
