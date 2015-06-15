class Generator < Event
  attr_accessor :total
  def initialize
    self.time = 0.0
  end

  def run(simulation)
    self.time = self.time + 10.seconds
    gen = Croupier::Distributions::Poisson.new(lambda: simulation.rate).generate_number

    gen.times do |i|
      customer = Customer.new
      # customer.arrived_at = self.time
      simulation.customers << customer

      check_in = CheckInStart.new(self.time, customer)
      simulation.schedule(check_in)
    end

    simulation.schedule(self) if simulation.end_time >= self.time
  end
end
