class Header
  attr_accessor :content_length

  def initialize(content_length)
    @content_length = content_length
  end

  def to_h
    {
      'host' => 'www.pcrbdata.com',
      'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0',
      'Accept' => '*/*',
      'Accept-Language' => 'tr,en-US;q=0.7,en;q=0.3',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Referer' => 'https://www.pcrbdata.com/PolicyCoverageInformation/PANameSearch',
      'Connection' => 'keep-alive',
      'Content-Length' => @content_length,
      'Origin' => 'https://www.ewccv.com',
      'X-MicrosoftAjax' => 'Delta=true',
      'X-Requested-With' => 'XMLHttpRequest',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8',
      'DNT' => '1'
    }
  end

end