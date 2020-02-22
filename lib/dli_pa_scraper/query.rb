require 'json'

class Query
  attr_accessor :event_validation, :view_state, :query

  def initialize(event_validation, view_state, company_name)
    # Use below code to search for the missing companies
    # company_name = URI.encode_www_form('txtNameSearch' => company_name)
    # Replace txtNameSearch=#{company_name} => #{company_name}

    company_name = company_name.tr('"', '')
    company_name = company_name.tr('.', '')
    company_name = URI.escape(company_name, '&#, ')

    @query = "ScriptManager1=UpdatePanel1%7CbtnSearch&txtNameSearch=#{company_name}&__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=#{view_state}&__VIEWSTATEGENERATOR=A26E68DB&__EVENTVALIDATION=#{event_validation}&__ASYNCPOST=true&btnSearch=Search"
  end

  def length
    @query.length
  end
end