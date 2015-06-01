require 'faker'

class Customer
  attr_accessor :arrived_at, :name

  def initialize
    @name = Faker::Name.name
  end

  # the customer arrived the ticket server
  # schedule to enter into buffet
  def arrived
  end

  # the customer picked his food
  def picked_food
  end

  # the customer paid and exit
  def paid
  end

end
