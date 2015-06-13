class Generator < Event
  attr_accessor :total
  def initialize
    self.time = 0.0
  end

  def run(simulation)
    # puts "SIMULATION: #{simulator} TIME: #{simulator.time} EVENTS: #{simulator.events.collect {|x| x.class.name }.inspect}"
    if self.total
      self.total += 1
    else
      self.total = 1
    end

    customer = Customer.new
    # @queue.insert(simulator, customer)

    # # reschedule this event
    # self.time = self.time + 6

    self.time = self.time + 30.seconds
    customer.arrived_at = self.time
    simulation.customers << customer

    # simulator.schedule(self) if self.time < 40

    # puts "#{customer.name} arrived at #{self.time}"
    check_in = CheckInStart.new(self.time, customer)
    simulation.schedule(check_in)
    # puts "Generator time: #{self.time}: #{self.time.to_f} < 10.0"
    # simulation.schedule(self) if self.total < 5
    simulation.schedule(self) if simulation.end_time >= self.time
  end
end
