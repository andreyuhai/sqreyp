require 'logger'
require 'mechanize'
require 'nokogiri'
require_relative 'query'
require_relative 'header'

class Bot
  attr_accessor :companies, :agent, :path, :view_state, :event_validation, :logger

  def initialize(companies, path)

    @logger = Logger.new('dli_pa.log')
    @companies = companies
    @path = path
    # proxy_host = 'proxy.crawlera.com'
    # proxy_api_key = '41557d71ce3044f4ba2d19d78cba2e41'

    @agent = Mechanize.new
    @agent.request_headers = {'Referer' => 'https://www.dli.pa.gov/Businesses/Compensation/WC/insurance/Pages/Workers-Compensation-Insurance-Search-Form.aspx'}
    # @agent.user_agent = Mechanize::AGENT_ALIASES['Linux Firefox']
    # @agent.ca_file = '/home/burak/Downloads/crawlera-ca.crt'
    # @agent.set_proxy proxy_host, 8010, proxy_api_key, ''
    @agent.open_timeout = 600
    @agent.ignore_bad_chunking = true

  end

  def start

    # Make initial request to get VIEWSTATE and EVENTVALIDATION
    response = @agent.get 'https://www.pcrbdata.com/PolicyCoverageInformation/PANameSearch'
    parsed = Nokogiri::HTML(response.body)
    @view_state = CGI.escape(parsed.css('#__VIEWSTATE').attr('value').text)
    @event_validation = CGI.escape(parsed.css('#__EVENTVALIDATION').attr('value').text)
    dir = File.dirname(path)
    filename = "#{Time.now.to_i}_scraped_" + File.basename(path)
    @saved_file_path = File.join(dir, filename)

    @companies.each do |company|
      puts "\n#{@companies.index(company) + 1}/#{@companies.count} | Searching for company name: #{company.company_name}"

      response = search_for_company(company.company_name)

      set_view_state(response.body)
      set_event_validation(response.body)
      matching_row = pick_row(response, company.file_number)

      next if matching_row.empty?

      sleep(rand(0..1))

      response = navigate_to_company_details(matching_row)


      scrape_company_details(company, response)

      puts "\n--------------------------------------------\n"
      sleep(rand(0..1))
    end
    @saved_file_path
  end

  def set_event_validation(response_body)
    @event_validation = CGI.escape(response_body[/(?<=EVENTVALIDATION\|).+?(?=\|)/])
  end

  def set_view_state(response_body)
    @view_state = CGI.escape(response_body[/(?<=VIEWSTATE\|).+?(?=\|)/])
  end

  def write_to_csv(path, company)
    CSV.open(@saved_file_path, 'a+') do |csv|
      if csv.count.zero?
        csv << ['File Number', 'Company Name', 'Employer Address',
                'FEIN', 'Policy Number', 'Insurance Carrier',	'NAIC',
                'Policy Effective Date', 'Policy Anniversary Date',
                'Policy Expiration Date',	'Policy Cancellation Date',	'No Current Policy Found']
      end
      csv << company.to_a
    end
  end

  def search_for_company(company_name)

    uri = 'https://www.pcrbdata.com/PolicyCoverageInformation/PANameSearch'

    query = Query.new @event_validation, @view_state, company_name
    header = Header.new query.length

    begin
      agent.post uri, query.query, header.to_h
    rescue Net::ReadTimeout, Net::HTTP::Persistent::Error
      puts "[#{company_name}]\tWaiting for 10 seconds"
      @logger.error "[#{company_name}]\tException message:#{$!} Stacktrace:#{$@}"
      sleep(10)
      retry
    end
  end

  def navigate_to_company_details(matching_row)
    query_string = matching_row[0].css('a').attr('onclick').text[/(?<=.aspx\?).+(?=')/]
    uri = "https://www.pcrbdata.com/PolicyCoverageInformation/PolicyCoverage?#{query_string}"
    agent.get uri
  end

  def pick_row(response, file_number)
    parsed_response = Nokogiri::HTML(response.body)
    rows = parsed_response.xpath("//table[@id='GridNameSearch']/tr").drop(1)

    matching_row = []
    rows.each do |row|
      if row.css('td')[4].text.to_i == file_number.to_i
        matching_row << row
        break
      end
    end
    matching_row
  end

  def scrape_company_details(company, response)
    parsed_response = Nokogiri::HTML(response.body)
    company.fein = parsed_response.xpath("//span[@id='lblFEIN']").text

    rows = parsed_response.xpath("//table[@id='GridPolicySearch']/tr").drop(1)

    most_recent_policies = []
    rows.each do |row|
      # binding.pry
      begin
        policy_expiration_date = Date.strptime(row.css('td')[5].text, '%m/%d/%y')
        policy_effective_date = Date.strptime(row.css('td')[3].text, '%m/%d/%y')
      rescue ArgumentError => e
        puts "There was something wrong with this date #{row.css('td')[5].text} : #{e.message}. Skipping..."
        @logger.error "[#{company.company_name}]\tThere was something wrong with this date #{row.css('td')[5].text}\n
                Exception message:#{$!} Stacktrace:#{$@}"
        next
      end

      if Date.today < policy_expiration_date && policy_effective_date <= Date.today
        most_recent_policies << row
      end
    end

    if most_recent_policies.empty?
      company.policy_cancelled = 'X'
      write_to_csv(@path, company)
    else
      most_recent_policies.each do |row|
        set_company_details(company, row)
        write_to_csv(@path, company)
      end
    end
  end

  def set_company_details(company, row)
    cells = row.css('td')
    company.policy_number = cells[0].text.strip
    company.insurance_carrier = cells[1].text.strip
    company.naic = cells[2].text.strip
    company.policy_effective_date = cells[3].text.strip
    company.policy_anniversary_date = cells[4].text.strip
    company.policy_expiration_date = cells[5].text.strip
    company.policy_cancellation_date = cells[6].text.strip
  end
end