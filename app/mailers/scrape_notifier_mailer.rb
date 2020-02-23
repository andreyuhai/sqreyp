class ScrapeNotifierMailer < ApplicationMailer
  default from: 'burakaymakci@gmail.com'

  def send_scrape_request_email(scrape_request)
    mail(to: scrape_request.email,
         subject: 'Scrape request has been received!')
  end

  def send_scrape_result_email(scrape_request)
    @download_link = Rails.application.routes.url_helpers.polymorphic_url(scrape_request.scrape_result.file,
                                                                          subdomain: 'sqreyp')
    mail(to: scrape_request.email,
         subject: 'Scrape result is ready!')
  end
end
