class Generator < Event
  attr_accessor :queue

  def initialize
    self.time = 0.0
  end

  def run(simulator)
    customer = Customer.new
    @queue.insert(simulator, customer)

    # reschedule this event
    self.time = self.time + 6

    simulator.schedule(self) if self.time < 40
  end
end
