class Company

  attr_accessor :file_number, :company_name, :employer_address, :fein, :policy_number, :insurance_carrier,
                :naic, :policy_effective_date, :policy_anniversary_date, :policy_expiration_date,
                :policy_cancellation_date, :policy_cancelled

  def initialize(row)

    @file_number = row[0]
    @company_name = row[1]
    @employer_address = row[2]

  end

  def to_a
    [@file_number, @company_name, @employer_address, @fein, @policy_number,
     @insurance_carrier, @naic, @policy_effective_date, @policy_anniversary_date,
     @policy_expiration_date, @policy_cancellation_date, @policy_cancelled]
  end
end