require 'faker'

class Customer
  attr_accessor :stats, :name

  def initialize
    @name = Faker::Name.name
    @stats = { check_in_queue: {}, payment_queue: {}, weight_queue: {} }
  end

  def collect(queue, action, event_time)
    @stats[queue][action] = event_time
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
