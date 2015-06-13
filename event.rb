class Event
  attr_accessor :time, :customer

  def initialize(time, customer)
    self.time = time
    self.customer = customer
  end
end
