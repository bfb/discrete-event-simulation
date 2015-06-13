class PaymentServer < Server
  def execute(simulation, customer)
    puts "Pagando #{customer.name}"
    if busy?
      puts "Error: server is busy!!!!!!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = 1.minute
    # self.time = simulation.time + service_time

    done = PaymentDone.new(simulation.time + service_time, customer)
    simulation.schedule(done)
    # @current = nil
  end
end
