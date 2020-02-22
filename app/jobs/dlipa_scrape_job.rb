class DlipaScrapeJob < ApplicationJob
  queue_as :default

  def perform(scrape_request)
    table = CSV.parse(scrape_request.file.download, headers: true)

    companies = []

    table.each do |row|
      companies << Company.new(row)
    end

    path = Rails.root.join("tmp/storage/#{scrape_request.file.filename}")
    bot = Bot.new(companies, path)
    save_path = bot.start
    scrape_result = scrape_request.create_scrape_result
    blob = ActiveStorage::Blob.create_and_upload!(io: File.open(save_path), filename: File.basename(save_path))
    scrape_result.file.attach(blob)
    ScrapeNotifierMailer.send_scrape_result_email(scrape_request).deliver
  end
end
