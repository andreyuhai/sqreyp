class ScrapeRequestsController < ApplicationController
  def new
    @scrape_request = ScrapeRequest.new
  end

  def create
    @scrape_request = ScrapeRequest.new(post_params)

    if @scrape_request.save
      redirect_to root_path, notice: %( Your scrape request has been successfully queued up!
                                    You should receive a confirmation email.)
    else
      redirect_to root_path, alert: 'Something went wrong! Please try again.'
    end
  end

  private

  def post_params
    params.require(:scrape_request).permit(:file, :email)
  end
end
